//
//  ViewController.swift
//  MoviesApp
//
//  Created by Любомир  Чорняк on 13.08.2023.
//

import UIKit
import Combine

struct MovieItem: Hashable {
    let title: String
    let posterPath: String?
    let id: Int
    
    let section: Categories
}

enum Categories: String {
    case nowPlayingMovies = "Now Playing"
    case upcomingMovies = "Upcoming"
    case topRatedMovies = "Top Rated"
    case popularMovies = "Popular"
    
    static func intToCategories(section: Int) -> Categories? {
        switch section {
        case 0: return .nowPlayingMovies
        case 1: return .upcomingMovies
        case 2: return .topRatedMovies
        case 3: return .popularMovies
        default: return nil
        }
    }
    
}

enum ActionType {
    case add
    case remove
}

class MainViewController: UIViewController {

    public var onMovieCellTapped: ((Int, UIImage) -> Void)?
    public var onListActionTapped: ((_ title: String, _ poster: UIImage?, _ id: Int, _ type: ActionType) -> Void)?

    private let viewModel: MainViewModelProtocol
    private let coreDataManager: CoreDataManagerProtocol
    
    private let popUpWindow = PopUpWindow(frame: .zero)
    
    private let collectionView: UICollectionView = {
        let collectionViewLayout = UICollectionViewLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: collectionViewLayout)
        collectionView.backgroundColor = .none
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    
    private enum Constants {
        static let titleElementKind = "title-element-kind"
        static let amountOfMoviesInPage = 20
        static let limitOfMoviesInSection = 200
        static let interGroupSpacing: CGFloat = 15
        static let sectionContentInset: CGFloat = 15
    }
    
    private var subscriptions = Set<AnyCancellable>()
    
    var dataSource: UICollectionViewDiffableDataSource<Categories, MovieItem>! = nil
    var currentSnapshot: NSDiffableDataSourceSnapshot<Categories, MovieItem>! = nil
    
    public let didTransitionSubject = PassthroughSubject<Void, Never>()
    
    private var contentOffsetsX: [CGFloat] = [0, 0, 0, 0]

    init(viewModel: MainViewModelProtocol, coreDataManager: CoreDataManagerProtocol) {
        self.viewModel = viewModel
        self.coreDataManager = coreDataManager
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()        
        setupViews()
        setConstraints()
        configureDataSource()
        
        setupBinders()
        getMovies()
    }
    
    private func getMovies() {
        viewModel.fetchAllMovies()
    }

    private func setupBinders() {
        
        viewModel.errorPublisher
            .dropFirst()
            .sink { [weak self] errorMessage in
                guard let self = self else { return }
                UIAlertController.showError(with: errorMessage, on: self)
            }
            .store(in: &subscriptions)
        
        viewModel.popularMoviesPublisher
            .sink { [weak self] movies in
                self?.appendMovies(movies ?? [], toSection: .popularMovies)
            }
            .store(in: &subscriptions)
        
        viewModel.upcomingMoviesPublisher
            .sink { [weak self] movies in
                self?.appendMovies(movies ?? [], toSection: .upcomingMovies)
            }
            .store(in: &subscriptions)

        viewModel.topRatedMoviesPublisher
            .sink { [weak self] movies in
                self?.appendMovies(movies ?? [], toSection: .topRatedMovies)
            }
            .store(in: &subscriptions)

        viewModel.nowPlayingMoviesPublisher
            .sink { [weak self] movies in
                self?.appendMovies(movies ?? [], toSection: .nowPlayingMovies)
            }
            .store(in: &subscriptions)
    }
    
     func appendMovies(_ movies: [MovieItem], toSection sectionIdentifier: Categories) {
         currentSnapshot.appendItems(movies, toSection: sectionIdentifier)
         dataSource.apply(self.currentSnapshot, animatingDifferences: true)
     }
    
    private func setupViews() {
        view.backgroundColor = .systemBackground

        collectionView.collectionViewLayout = createLayout()
        collectionView.delegate = self
        view.addSubview(collectionView)
        
        title = "Main"
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    private func setConstraints() {
        collectionView.snp.makeConstraints { make in
            make.leading.trailing.top.bottom.equalToSuperview()
        }
    }
    
    private func configureDataSource() {
        
        let cellRegistration = UICollectionView.CellRegistration<MainCollectionViewCell, MovieItem> { cell, indexPath, movie in
            cell.configure(with: movie.posterPath, title: movie.title)
        }
        dataSource = UICollectionViewDiffableDataSource(collectionView: collectionView) {
            (collectionView: UICollectionView, indexPath: IndexPath, movie: MovieItem) -> UICollectionViewCell? in
            return collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: movie)
        }
        
        let supplementaryRegistration = UICollectionView.SupplementaryRegistration<TitleSupplementaryView>(elementKind: Constants.titleElementKind) { supplementaryView, elementKind, indexPath in
            
            if let snapShot = self.currentSnapshot {
                let movieCategory = snapShot.sectionIdentifiers[indexPath.section]
                supplementaryView.label.text = movieCategory.rawValue
            }
        }
        
        dataSource.supplementaryViewProvider = { view, kind, index in
            return self.collectionView.dequeueConfiguredReusableSupplementary(using: supplementaryRegistration, for: index)
        }
        
        currentSnapshot = NSDiffableDataSourceSnapshot<Categories, MovieItem>()
        currentSnapshot.appendSections([.nowPlayingMovies, .upcomingMovies, .topRatedMovies, .popularMovies])
        dataSource.apply(currentSnapshot, animatingDifferences: true)

    }
    
}

// MARK: - Create Layout
extension MainViewController {
    
    private func createLayout() -> UICollectionViewCompositionalLayout {
       
        let sectionProvider = { (sectionIndex: Int, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
            
            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
 
            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.425), heightDimension: .fractionalWidth(0.425  * GlobalConstants.posterAspectRatio ) )
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
            
            let section = NSCollectionLayoutSection(group: group)
            section.orthogonalScrollingBehavior = .continuous
            section.interGroupSpacing = Constants.interGroupSpacing
            section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: Constants.sectionContentInset, bottom: 0, trailing: Constants.sectionContentInset)
            
            section.visibleItemsInvalidationHandler = { [weak self] visibleItems, point, environment in
                self?.horizontalSectionDidScroll(visibleItems: visibleItems, point: point, environment: environment, sectionIndex: sectionIndex)
            }
            
            let titleSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(44))
            let titleSupplementary = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: titleSize, elementKind: Constants.titleElementKind, alignment: .top)
            section.boundarySupplementaryItems = [titleSupplementary]
            return section
        }
        
        let config = UICollectionViewCompositionalLayoutConfiguration()
        config.interSectionSpacing = 20
        let layout = UICollectionViewCompositionalLayout(sectionProvider: sectionProvider, configuration: config)
        return layout
        
    }
    
    private func horizontalSectionDidScroll(visibleItems: [NSCollectionLayoutVisibleItem], point: CGPoint, environment: NSCollectionLayoutEnvironment, sectionIndex: Int) {
        let contentOffset = point.x
        setOffset(for: sectionIndex, offset: contentOffset)
        guard let itemWidth = visibleItems.last?.frame.width else { return }
        var section: Categories
        switch sectionIndex {
        case 0: section = .nowPlayingMovies
        case 1: section = .upcomingMovies
        case 2: section = .topRatedMovies
        case 3: section = .popularMovies
        default: return
        }
        let amountOfItemsInSection = self.currentSnapshot.itemIdentifiers(inSection: section).count
        if amountOfItemsInSection > Constants.limitOfMoviesInSection { return }
        if amountOfItemsInSection == 0 { return }
        let contentSize = CGFloat(amountOfItemsInSection) * itemWidth + (2 * Constants.sectionContentInset) + ((CGFloat(amountOfItemsInSection) - 1) * Constants.interGroupSpacing)

        if contentOffset > (contentSize + 20 - environment.container.contentSize.width) {
            switch sectionIndex {
            case 0:
                guard !self.viewModel.isNowPlayingPaginating else { return }
                self.viewModel.fetchNowPlayingMovies(page: (amountOfItemsInSection / Constants.amountOfMoviesInPage) + 1 )
            case 1:
                guard !self.viewModel.isUpcomingPaginating else { return }
                self.viewModel.fetchUpcomingMovies(page: (amountOfItemsInSection / Constants.amountOfMoviesInPage) + 1 )
            case 2:
                guard !self.viewModel.isTopRatedPaginating else { return }
                self.viewModel.fetchTopRatedMovies(page: (amountOfItemsInSection / Constants.amountOfMoviesInPage) + 1 )
            case 3:
                guard !self.viewModel.isPopularPaginating else { return }
                self.viewModel.fetchPopularMovies(page: (amountOfItemsInSection / Constants.amountOfMoviesInPage) + 1 )
            default:
                break
            }
        }
    }
}

extension MainViewController {
    
    public func showPopUp(with message: String) {
        popUpWindow.show(with: message, on: view)
    }
    
}
 
// MARK: - Transition animation
extension MainViewController {
    public func selectedCell() -> MainCollectionViewCell? {
        guard let indexPath = collectionView.indexPathsForSelectedItems?.first else { return nil }
        guard let cell = collectionView.cellForItem(at: indexPath) as? MainCollectionViewCell else { return nil }
        return cell
    }
    
    public func getOrigin() -> CGPoint? {
        guard let indexPath = collectionView.indexPathsForSelectedItems?.first else { return nil }
        guard let cell = collectionView.cellForItem(at: indexPath) as? MainCollectionViewCell else { return nil }

        let contentOffsetY = collectionView.contentOffset.y
        let contentOffsetX = getOffset(for: indexPath.section)

        let origin = CGPoint(x: cell.frame.origin.x - contentOffsetX, y: cell.frame.origin.y - contentOffsetY)
        return origin
    }
    
    private func getOffset(for section: Int) -> CGFloat {
        switch(section) {
        case 0: return contentOffsetsX[section]
        case 1: return contentOffsetsX[section]
        case 2: return contentOffsetsX[section]
        case 3: return contentOffsetsX[section]
        default: return CGFloat()
        }
    }
    
    private func setOffset(for section: Int, offset: CGFloat) {
        switch(section) {
        case 0: contentOffsetsX[section] = offset
        case 1: contentOffsetsX[section] = offset
        case 2: contentOffsetsX[section] = offset
        case 3: contentOffsetsX[section] = offset
        default: break
        }
    }
}

// MARK: - UICollectionViewDelegate

extension MainViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! MainCollectionViewCell
        let section = currentSnapshot.sectionIdentifiers[indexPath.section]
        let item = currentSnapshot.itemIdentifiers(inSection: section)[indexPath.item]
        let id = item.id
        onMovieCellTapped?(id, cell.posterImageView.image ?? GlobalConstants.defaultImage)
    }
    
    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemsAt indexPaths: [IndexPath], point: CGPoint) -> UIContextMenuConfiguration? {
        
        guard !indexPaths.isEmpty else { return nil }
        let indexPath = indexPaths[0]
        
        guard let cell = collectionView.cellForItem(at: indexPath) as? MainCollectionViewCell else { return nil }
        guard let section = Categories.intToCategories(section: indexPath.section) else { return nil }
        let itemInfo = self.currentSnapshot.itemIdentifiers(inSection: section)[indexPath.item]
        let listsInWhichMovieIsStored = self.coreDataManager.fetchListsInWhichMovieIsStored(movieId: itemInfo.id)

        let config = UIContextMenuConfiguration(listsInWhichMovieIsStored: listsInWhichMovieIsStored,
                                                title: itemInfo.title,
                                                poster: cell.posterImageView.image,
                                                id: itemInfo.id,
                                                onListActionTapped: onListActionTapped)
        
        return config
        
    }
   
}

