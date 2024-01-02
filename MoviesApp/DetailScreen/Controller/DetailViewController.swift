import UIKit
import WebKit
import Combine

enum DetailSection: Int, Hashable, CaseIterable, CustomStringConvertible {
    
    case main
    case overview
    case cast
    case trailers
    case reviews

    var description: String {
        switch self {
        case .overview: return "Overview"
        case .cast: return "Cast"
        case .trailers: return "Trailers"
        case .reviews: return "Reviews"
        default: return ""
        }
    }
}

struct DetailItem: Hashable {

    let movieInfo: ExtendedMovieModel?
    let overview: String?
    let castMember: Actor?
    let trailer: Trailer?
    let review: Review?

    init(movieInfo: ExtendedMovieModel? = nil, overview: String? = nil, cast: Actor? = nil, trailer: Trailer? = nil, review: Review? = nil) {
        self.movieInfo = movieInfo
        self.castMember = cast
        self.trailer = trailer
        self.review = review
        self.overview = overview
    }

}

class DetailViewController: UIViewController {

    // MARK: - Properties
    var completionHandler: (() -> Void)?
    
    private let viewModel: DetailViewModelProtocol

    var dataSource: UICollectionViewDiffableDataSource<DetailSection, DetailItem>! = nil
    var currentSnapshot: NSDiffableDataSourceSnapshot<DetailSection, DetailItem>! = nil
   
    
    var viewsAreHidden: Bool = false {
        didSet {
            closeButton.isHidden = viewsAreHidden
            
            for cell in collectionView.visibleCells {
                cell.isHidden = viewsAreHidden
            }
            
            for header in collectionView.visibleSupplementaryViews(ofKind: Constants.titleElementKind) {
                header.isHidden = viewsAreHidden
            }
        
            view.backgroundColor = viewsAreHidden ? .clear : .white
        }
    }

    var expandedcell: IndexSet = []
    var subscriptions = Set<AnyCancellable>()

    enum Constants {
        static let titleElementKind = "title-element-kind"
        static let collectionViewContentInset: CGFloat = 30
        static let closeButtonWidth: CGFloat = 30
    }

    let movieId: Int
    let moviePoster: UIImage

    // MARK: - init
    init(movieId: Int, moviePoster: UIImage, viewModel: DetailViewModelProtocol) {
        self.movieId = movieId
        self.moviePoster = moviePoster
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - UI properties
    private let collectionView: UICollectionView = {
        let collectionViewLayout = UICollectionViewLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: collectionViewLayout)
        collectionView.backgroundColor = .none
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.isHidden = true
        return collectionView
    }()
    
    private lazy var closeButton: UIButton = {
        let button = UIButton()
        if self.traitCollection.userInterfaceStyle == .light {
            button.setImage(UIImage(named: "darkOnLight"), for: .normal)
        } else {
            button.setImage(UIImage(named: "lightOnDark"), for: .normal)
        }
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(close), for: .touchUpInside)
        return button
    }()
    
    lazy var snapshotView: UIImageView = {
        let imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.backgroundColor = .white
        imageView.layer.shadowColor = UIColor.black.cgColor
        imageView.layer.shadowOpacity = 0.2
        imageView.layer.shadowRadius = 10.0
        imageView.layer.shadowOffset = CGSize(width: -1, height: 2)
        imageView.isHidden = true
        return imageView
    }()
    
    private let activityIndicatorView = UIActivityIndicatorView(style: .large)
    
    // MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        activityIndicatorView.startAnimating()
        collectionView.delegate = self
        setupViews()
        setConstraints()
        configureDataSource()
        setupBinders()
        viewModel.fetchInfo(id: movieId)
        collectionView.contentInset = .init(top: Constants.collectionViewContentInset, left: 0, bottom: 0, right: 0)
    }
  
    private func setupBinders() {
        
        viewModel.errorPublisher
            .dropFirst()
            .sink { [weak self] errorMessage in
                guard let self = self else { return }
                UIAlertController.showError(with: errorMessage, on: self)
            }
            .store(in: &subscriptions)
        
        viewModel.extendedMovieInfoPublisher
            .dropFirst()
            .sink { [weak self] movieInfo in
                guard let self = self else { return }
                let item = DetailItem(movieInfo: movieInfo)
                var snapShot = NSDiffableDataSourceSectionSnapshot<DetailItem>()
                snapShot.append([item])
                self.currentSnapshot.appendItems([item], toSection: .main)
                self.activityIndicatorView.stopAnimating()
                self.collectionView.isHidden = false
                self.dataSource.apply(snapShot, to: .main, animatingDifferences: true)
            }
            .store(in: &subscriptions)

        viewModel.overviewPublisher
            .dropFirst()
            .sink { [weak self] overview in
                guard let self = self else { return }
                let item = DetailItem(overview: overview)
                var snapShot = NSDiffableDataSourceSectionSnapshot<DetailItem>()
                snapShot.append([item])
                self.currentSnapshot.appendItems([item], toSection: .overview)
                self.dataSource.apply(snapShot, to: .overview, animatingDifferences: true)
            }
            .store(in: &subscriptions)

        viewModel.castPublisher
            .dropFirst()
            .sink { [weak self] cast in
                guard let self = self else { return }
                let items = cast.map({ DetailItem(cast: $0) })
                var snapShot = NSDiffableDataSourceSectionSnapshot<DetailItem>()
                snapShot.append(items)
                self.currentSnapshot.appendItems(items, toSection: .cast)
                self.dataSource.apply(snapShot, to: .cast, animatingDifferences: true)
            }
            .store(in: &subscriptions)

        viewModel.trailersPublisher
            .dropFirst()
            .sink { [weak self] trailers in
                guard let self = self else { return }
                let items = trailers.map({ DetailItem(trailer: $0) })
                var snapShot = NSDiffableDataSourceSectionSnapshot<DetailItem>()
                snapShot.append(items)
                self.currentSnapshot.appendItems(items, toSection: .trailers)
                self.dataSource.apply(snapShot, to: .trailers, animatingDifferences: true)
            }
            .store(in: &subscriptions)

        viewModel.reviewsPublisher
            .dropFirst()
            .sink { [weak self] comments in
                guard let self = self else { return }
                let items = comments.map({ DetailItem(review: $0) })
                var snapShot = NSDiffableDataSourceSectionSnapshot<DetailItem>()
                snapShot.append(items)
                self.currentSnapshot.appendItems(items, toSection: .reviews)
                self.dataSource.apply(snapShot, to: .reviews, animatingDifferences: true)
            }
            .store(in: &subscriptions)

    }

    private func setupViews() {
        view.backgroundColor = .systemBackground
        collectionView.collectionViewLayout = createLayout()
        view.addSubview(collectionView)
        view.addSubview(closeButton)
    }

    private func setConstraints() {
        collectionView.snp.makeConstraints { make in
            make.leading.trailing.top.bottom.equalToSuperview()
        }
        
        closeButton.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(5)
            make.trailing.equalToSuperview().inset(20)
            make.width.height.equalTo(Constants.closeButtonWidth)
        }
    }
    
    // MARK: - objc
    @objc func close() {
        completionHandler?()
    }
}

// MARK: - Helpers
extension DetailViewController {
    func createSnapshotOfView() {
    
        let snapshotImage = self.view.createSnapshot()

        snapshotView.image = snapshotImage
        collectionView.addSubview(snapshotView)

        let topPadding = UIWindow.topPadding
        snapshotView.frame = CGRect(x: 0, y: -topPadding, width: view.frame.size.width, height: view.frame.size.height)

    }
    
    public func getPosterView() -> UIImageView {
        if let detailCollectionViewCell = collectionView.visibleCells[0] as? DetailCollectionViewCell {
            let posterView = detailCollectionViewCell.posterImageView
            return posterView
        }
        return UIImageView()
    }
    
}

// MARK: - UICollectionViewDelegate
extension DetailViewController: UICollectionViewDelegate {

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        updateCloseButton(offset: scrollView.contentOffset.y)
        
        let yPositionForDismissal: CGFloat = 70.0
        let yContentOffset = scrollView.contentOffset.y + UIWindow.topPadding + Constants.collectionViewContentInset
        if scrollView.isTracking {
            scrollView.bounces = true
        } else {
            scrollView.bounces = yContentOffset > 500
        }

        if yContentOffset < 0 && scrollView.isTracking {
            if !viewsAreHidden {
                snapshotView.image = self.view.createSnapshot()
            }
            viewsAreHidden = true
            snapshotView.isHidden = false
            
            let scale = (100 + yContentOffset) / 100
            snapshotView.transform = CGAffineTransform(scaleX: scale, y: scale)

            snapshotView.layer.cornerRadius = -yContentOffset > yPositionForDismissal ? yPositionForDismissal : -yContentOffset

            if yPositionForDismissal + yContentOffset <= 0 {
                self.close()
            }

        } else {
            viewsAreHidden = false
            snapshotView.isHidden = true
        }
        
    }
    
    private func updateCloseButton(offset: CGFloat) {
        let yContentOffset = offset + UIWindow.topPadding + Constants.collectionViewContentInset
        if yContentOffset > 120 {
            closeButton.alpha = 1 - (yContentOffset - 120) / 60
        } else {
            closeButton.alpha = 1
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        scrollView.bounces = true
    }
    
}


// MARK: - Data Source
extension DetailViewController {
    
    private func createMainCellRegistration() -> UICollectionView.CellRegistration<DetailCollectionViewCell, ExtendedMovieModel> {
        UICollectionView.CellRegistration<DetailCollectionViewCell, ExtendedMovieModel> { [weak self] (cell, indexPath, movieInfo) in
            guard let self = self else { return }
            let config = DetailCollectionViewCellConfiguration(
                posterImage: self.moviePoster,
                title: movieInfo.title,
                tagline: movieInfo.tagline,
                averageVote: movieInfo.voteAverage,
                genres: movieInfo.genres.map({ Genre(rawValue: $0.name) ?? .all }),
                duration: movieInfo.runtime)
            cell.configureCell(with: config)
        }
    }

    private func createOverviewCellRegistration() -> UICollectionView.CellRegistration<OverviewCollectionViewCell, String> {
        UICollectionView.CellRegistration<OverviewCollectionViewCell, String> { (cell, indexPath, overview) in
            cell.configure(with: overview)
        }
    }

    private func createCastCellRegistration() -> UICollectionView.CellRegistration<CastCollectionViewCell, Actor> {
        UICollectionView.CellRegistration<CastCollectionViewCell, Actor> { (cell, indexPath, movieActor) in
            cell.configure(with: movieActor.profilePath, actorName: movieActor.name)
        }
    }

    private func createTrailerCellRegistration() -> UICollectionView.CellRegistration<TrailerCollectionViewCell, Trailer> {
        UICollectionView.CellRegistration<TrailerCollectionViewCell, Trailer> { (cell, indexPath, trailer) in
            cell.configureCell(with: trailer.key)
        }
    }

    private func createReviewCellRegistration() -> UICollectionView.CellRegistration<CommentCollectionViewCell, Review> {
        UICollectionView.CellRegistration<CommentCollectionViewCell, Review> { [weak self] (cell, indexPath, commentInfo) in
            //guard let self = self else { return }
            
            let config = CommentCollectionViewCellConfiguration(
                avatarImageUrl: commentInfo.authorDetails.avatarPath,
                name: commentInfo.author,
                comment: commentInfo.content,
                date: commentInfo.createdAt,
                ratings: commentInfo.authorDetails.rating ?? 0)
            cell.configure(with: config)

            let isExpandedCell = self?.expandedcell.contains(indexPath.item)
            if let isExpandedCell, isExpandedCell == true {
                cell.commentLabel.numberOfLines = 0
                cell.moreButton.setTitle("See Less", for: .normal)
            } else {
                cell.commentLabel.numberOfLines = 3
                cell.moreButton.setTitle("See More", for: .normal)
            }
            
            cell.buttonClicked = {
                guard let self = self else { return }
                if self.expandedcell.contains(indexPath.item) {
                    self.expandedcell.remove(indexPath.item)
                } else {
                    self.expandedcell.insert(indexPath.item)
                }

                self.currentSnapshot.reloadItems([ DetailItem(review: commentInfo) ])
                self.dataSource.apply(self.currentSnapshot, animatingDifferences: false)
                self.view.layoutIfNeeded()
            }
        }
    }
    
    private func configureDataSource() {
        let mainCellRegistration = createMainCellRegistration()
        let overviewCellRegistration = createOverviewCellRegistration()
        let castCellRegistration = createCastCellRegistration()
        let trailerCellRegistration = createTrailerCellRegistration()
        let reviewCellRegistration = createReviewCellRegistration()

        dataSource = UICollectionViewDiffableDataSource(collectionView: collectionView) {
            (collectionView: UICollectionView, indexPath: IndexPath, item: DetailItem) -> UICollectionViewCell? in
            guard let section = DetailSection(rawValue: indexPath.section) else { return nil }
            switch section {
            case .main:
                print("\(item.movieInfo == nil)")
                return collectionView.dequeueConfiguredReusableCell(using: mainCellRegistration, for: indexPath, item: item.movieInfo)
            case .overview:
                return collectionView.dequeueConfiguredReusableCell(using: overviewCellRegistration, for: indexPath, item: item.overview)
            case .cast:
                return collectionView.dequeueConfiguredReusableCell(using: castCellRegistration, for: indexPath, item: item.castMember)
            case .trailers:
                return collectionView.dequeueConfiguredReusableCell(using: trailerCellRegistration, for: indexPath, item: item.trailer)
            case .reviews:
                return collectionView.dequeueConfiguredReusableCell(using: reviewCellRegistration, for: indexPath, item: item.review)
            }
            
        }

        let supplementaryRegistration = UICollectionView.SupplementaryRegistration<TitleSupplementaryView>(elementKind: Constants.titleElementKind) { [weak self] supplementaryView, elementKind, indexPath in
            guard let self = self else { return }
            if let snapShot = self.currentSnapshot {
                let section = snapShot.sectionIdentifiers[indexPath.section]
                supplementaryView.label.text = section.description
            }
        }

        dataSource.supplementaryViewProvider = { [weak self] view, kind, index in
            guard let self = self else { return nil }
            guard let section = DetailSection(rawValue: index.section) else { return nil }
            if section != .main {
                return self.collectionView.dequeueConfiguredReusableSupplementary(using: supplementaryRegistration, for: index)
            }
            
            return nil
        }

        let sections = DetailSection.allCases
        currentSnapshot = NSDiffableDataSourceSnapshot<DetailSection, DetailItem>()
        currentSnapshot.appendSections(sections)
        dataSource.apply(currentSnapshot, animatingDifferences: false)
    }
    
}

// MARK: Collection View Layout
extension DetailViewController {

    private func createLayout() -> UICollectionViewCompositionalLayout {

        let sectionProvider = { (sectionIndex: Int, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in

            guard let sectionKind = DetailSection(rawValue: sectionIndex) else { return nil }
            let section: NSCollectionLayoutSection

            switch sectionKind {
            case .main:
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(300))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(300))
                let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
                section = NSCollectionLayoutSection(group: group)
                section.contentInsets = NSDirectionalEdgeInsets(top: 30, leading: 10, bottom: 10, trailing: 10)

            case .overview:
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(100))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(100))
                let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
                section = NSCollectionLayoutSection(group: group)
                section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10)

            case .cast:
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                let groupSize = NSCollectionLayoutSize(widthDimension: .absolute(110), heightDimension: .fractionalHeight(0.2))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
                section = NSCollectionLayoutSection(group: group)
                section.interGroupSpacing = 10
                section.orthogonalScrollingBehavior = .continuousGroupLeadingBoundary
                section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10)

            case .trailers:
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.7), heightDimension: .fractionalHeight(0.3))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
                section = NSCollectionLayoutSection(group: group)
                section.interGroupSpacing = 10
                section.orthogonalScrollingBehavior = .groupPaging
                section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10)

            case .reviews:
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(200))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(200))
                let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
                section = NSCollectionLayoutSection(group: group)
                section.interGroupSpacing = 10
                section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10)
            }

            if sectionKind != .main {
                let titleSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(44))
                let titleSupplementary = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: titleSize, elementKind: Constants.titleElementKind, alignment: .top)
                section.boundarySupplementaryItems = [titleSupplementary]
            }

            return section
        }

        let config = UICollectionViewCompositionalLayoutConfiguration()
        config.interSectionSpacing = 20
        let layout = UICollectionViewCompositionalLayout(sectionProvider: sectionProvider, configuration: config)
        return layout

    }
}

