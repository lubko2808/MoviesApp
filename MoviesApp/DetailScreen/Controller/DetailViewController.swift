import UIKit
import WebKit
import Combine

class DetailViewController: UIViewController {

    // MARK: - Properties
    var completionHandler: (() -> Void)?
    
    private let viewModel: DetailViewModelProtocol

    typealias Section = DetailScreenCollectionView.Section
    typealias Item = DetailScreenCollectionView.Item
   
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
    private let collectionView = DetailScreenCollectionView()
    
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
        setupBinders()
        viewModel.fetchInfo(id: movieId)
        collectionView.contentInset = .init(top: Constants.collectionViewContentInset, left: 0, bottom: 0, right: 0)
    }

    private func setupBinders() {
        
        viewModel.errorPublisher
            .dropFirst()
            .sink { [weak self] errorMessage in
                guard let self = self else { return }
                self.showError(with: errorMessage)
            }
            .store(in: &subscriptions)
        
        viewModel.extendedMovieInfoPublisher
            .dropFirst()
            .sink { [weak self] movieInfo in
                guard let self = self, let movieInfo else { return }
                let item = Item.main(DetailMovieModel(posterImage: moviePoster, extendedMovieModel: movieInfo))
                self.activityIndicatorView.stopAnimating()
                self.collectionView.isHidden = false
                self.collectionView.appendItems([item], to: .main)
            }
            .store(in: &subscriptions)

        viewModel.overviewPublisher
            .dropFirst()
            .sink { [weak self] overview in
                guard let self = self else { return }
                let item = Item.overview(overview)
                self.collectionView.appendItems([item], to: .overview)
            }
            .store(in: &subscriptions)

        viewModel.castPublisher
            .dropFirst()
            .sink { [weak self] cast in
                guard let self = self else { return }
                let items = cast.map { Item.castMember($0) }
                self.collectionView.appendItems(items, to: .cast)
            }
            .store(in: &subscriptions)

        viewModel.trailersPublisher
            .dropFirst()
            .sink { [weak self] trailers in
                guard let self = self else { return }
                let items = trailers.map { Item.trailer($0) }
                self.collectionView.appendItems(items, to: .trailers)
            }
            .store(in: &subscriptions)

        viewModel.reviewsPublisher
            .dropFirst()
            .sink { [weak self] comments in
                guard let self = self else { return }
                let items = comments.map { Item.review($0) }
                self.collectionView.appendItems(items, to: .reviews)
            }
            .store(in: &subscriptions)
        
    }
     
    private func setupViews() {
        view.backgroundColor = .systemBackground
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

