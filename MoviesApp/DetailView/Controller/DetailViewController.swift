import UIKit
import WebKit
import Combine

enum Section: Int, Hashable, CaseIterable, CustomStringConvertible {
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

struct Item: Hashable {

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

    private let viewModel = DetailViewModel(networkManager: NetworkManager())

    var dataSource: UICollectionViewDiffableDataSource<Section, Item>! = nil
    var currentSnapshot: NSDiffableDataSourceSnapshot<Section, Item>! = nil

    enum Constants {
        static let titleElementKind = "title-element-kind"
    }

    let movieId: Int
    let moviePoster: UIImage

    init(movieId: Int, moviePoster: UIImage) {
        self.movieId = movieId
        self.moviePoster = moviePoster
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


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

    var expandedcell: IndexSet = []
    var subscriptions = Set<AnyCancellable>()
    
    private let activityIndicatorView = UIActivityIndicatorView(style: .large)

    override func viewDidLoad() {
        super.viewDidLoad()
        activityIndicatorView.startAnimating()
        
        setupViews()
        setConstraints()
        configureDataSource()

        setupBinders()
        viewModel.fetchInfo(id: movieId)
        
    }
  
    private func setupBinders() {
        
        viewModel.$error
            .dropFirst()
            .sink { [weak self] errorMessage in
                self?.showError(message: errorMessage)
            }
            .store(in: &subscriptions)
        
        viewModel.$extendedMovieInfo
            .dropFirst()
            .sink { [weak self] movieInfo in
                guard let self = self else { return }
                let item = Item(movieInfo: movieInfo)
                var snapShot = NSDiffableDataSourceSectionSnapshot<Item>()
                snapShot.append([item])
                self.currentSnapshot.appendItems([item], toSection: .main)
                self.activityIndicatorView.stopAnimating()
                self.collectionView.isHidden = false
                self.dataSource.apply(snapShot, to: .main, animatingDifferences: true)
            }
            .store(in: &subscriptions)

        viewModel.$overview
            .dropFirst()
            .sink { [weak self] overview in
                guard let self = self else { return }
                let item = Item(overview: overview)
                var snapShot = NSDiffableDataSourceSectionSnapshot<Item>()
                snapShot.append([item])
                self.currentSnapshot.appendItems([item], toSection: .overview)
                self.dataSource.apply(snapShot, to: .overview, animatingDifferences: true)
            }
            .store(in: &subscriptions)

        viewModel.$cast
            .dropFirst()
            .sink { [weak self] cast in
                guard let self = self else { return }
                let items = cast.map({ Item(cast: $0) })
                var snapShot = NSDiffableDataSourceSectionSnapshot<Item>()
                snapShot.append(items)
                self.currentSnapshot.appendItems(items, toSection: .cast)
                self.dataSource.apply(snapShot, to: .cast, animatingDifferences: true)
            }
            .store(in: &subscriptions)

        viewModel.$trailers
            .dropFirst()
            .sink { [weak self] trailers in
                guard let self = self else { return }
                let items = trailers.map({ Item(trailer: $0) })
                var snapShot = NSDiffableDataSourceSectionSnapshot<Item>()
                snapShot.append(items)
                self.currentSnapshot.appendItems(items, toSection: .trailers)
                self.dataSource.apply(snapShot, to: .trailers, animatingDifferences: true)
            }
            .store(in: &subscriptions)

        viewModel.$reviews
            .dropFirst()
            .sink { [weak self] comments in
                guard let self = self else { return }
                let items = comments.map({ Item(review: $0) })
                var snapShot = NSDiffableDataSourceSectionSnapshot<Item>()
                snapShot.append(items)
                self.currentSnapshot.appendItems(items, toSection: .reviews)
                self.dataSource.apply(snapShot, to: .reviews, animatingDifferences: true)
            }
            .store(in: &subscriptions)

    }

    private func showError(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        print("show Error: \(Thread.current)")
        present(alert, animated: true, completion: nil)
    }

    private func setupViews() {
        view.backgroundColor = .systemBackground
        collectionView.collectionViewLayout = createLayout()
        view.addSubview(collectionView)
        view.addSubview(activityIndicatorView)
    }

    private func setConstraints() {
        collectionView.snp.makeConstraints { make in
            make.leading.trailing.top.bottom.equalToSuperview()
        }
        
        activityIndicatorView.snp.makeConstraints { make in
            make.leading.trailing.top.bottom.equalToSuperview()
        }
    }
}


// MARK: - Data Source
extension DetailViewController {
    
    private func createMainCellRegistration() -> UICollectionView.CellRegistration<DetailCollectionViewCell, ExtendedMovieModel> {
        UICollectionView.CellRegistration<DetailCollectionViewCell, ExtendedMovieModel> { (cell, indexPath, movieInfo) in
            let config = DetailCollectionViewCellConfiguration(
                posterImage: self.moviePoster,
                title: movieInfo.title,
                tagline: movieInfo.tagline,
                averageVote: movieInfo.vote_average,
                genres: movieInfo.genres.map({ $0.id }),
                duration: movieInfo.runtime)
            cell.configureCell(with: config)
            self.view.layoutIfNeeded()
        }
    }

    private func createOverviewCellRegistration() -> UICollectionView.CellRegistration<OverviewCollectionViewCell, String> {
        UICollectionView.CellRegistration<OverviewCollectionViewCell, String> { (cell, indexPath, overview) in
            cell.configure(with: overview)
        }
    }

    private func createCastCellRegistration() -> UICollectionView.CellRegistration<CastCollectionViewCell, Actor> {
        UICollectionView.CellRegistration<CastCollectionViewCell, Actor> { (cell, indexPath, movieActor) in
            cell.configure(with: movieActor.profile_path, actorName: movieActor.name)
        }
    }

    private func createTrailerCellRegistration() -> UICollectionView.CellRegistration<TrailerCollectionViewCell, Trailer> {
        UICollectionView.CellRegistration<TrailerCollectionViewCell, Trailer> { (cell, indexPath, trailer) in
            cell.configureCell(with: trailer.key)
        }
    }

    private func createReviewCellRegistration() -> UICollectionView.CellRegistration<CommentCollectionViewCell, Review> {
        UICollectionView.CellRegistration<CommentCollectionViewCell, Review> { (cell, indexPath, commentInfo) in

            
            let config = CommentCollectionViewCellConfiguration(
                avatarImageUrl: commentInfo.author_details.avatar_path,
                name: commentInfo.author,
                comment: commentInfo.content,
                date: commentInfo.created_at,
                ratings: commentInfo.author_details.rating ?? 0)
            cell.configure(with: config)

            if self.expandedcell.contains(indexPath.item) {
                cell.commentLabel.numberOfLines = 0
                cell.moreButton.setTitle("See Less", for: .normal)
            } else {
                cell.commentLabel.numberOfLines = 3
                cell.moreButton.setTitle("See More", for: .normal)
            }

            cell.buttonClicked = {
                if self.expandedcell.contains(indexPath.item) {
                    self.expandedcell.remove(indexPath.item)
                } else {
                    self.expandedcell.insert(indexPath.item)
                }

                self.currentSnapshot.reloadItems([ Item(review: commentInfo) ])
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
            (collectionView: UICollectionView, indexPath: IndexPath, item: Item) -> UICollectionViewCell? in
            guard let section = Section(rawValue: indexPath.section) else { return nil }
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

        let supplementaryRegistration = UICollectionView.SupplementaryRegistration<TitleSupplementaryView>(elementKind: Constants.titleElementKind) { supplementaryView, elementKind, indexPath in

            if let snapShot = self.currentSnapshot {
                let section = snapShot.sectionIdentifiers[indexPath.section]
                supplementaryView.label.text = section.description
            }
        }

        dataSource.supplementaryViewProvider = { view, kind, index in
            guard let section = Section(rawValue: index.section) else { return nil }
            if section != .main {
                return self.collectionView.dequeueConfiguredReusableSupplementary(using: supplementaryRegistration, for: index)
            }
            
            return nil
        }

        let sections = Section.allCases
        currentSnapshot = NSDiffableDataSourceSnapshot<Section, Item>()
        currentSnapshot.appendSections(sections)
        dataSource.apply(currentSnapshot, animatingDifferences: false)
    }
    
    
    
     
}


// MARK: Collection View Layout
extension DetailViewController {

    private func createLayout() -> UICollectionViewCompositionalLayout {

        let sectionProvider = { (sectionIndex: Int, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in

            guard let sectionKind = Section(rawValue: sectionIndex) else { return nil }
            let section: NSCollectionLayoutSection

            switch sectionKind {
            case .main:
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(0.4))
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























