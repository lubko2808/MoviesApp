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

class MainViewController: UIViewController {
    
    private let viewModel = MainViewModel(networkManager: NetworkManager())
    private let coreDataManager = CoreDataManager.shared
    
    private let popUpWindow: PopUpWindow = {
        let view = PopUpWindow(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
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
        static let posterAspectRatio: CGFloat = 3 / 2
        static let amountOfMoviesInPage = 20
        static let limitOfMoviesInSection = 200
        static let interGroupSpacing: CGFloat = 15
        static let sectionContentInset: CGFloat = 15
    }
    
    private var subscriptions = Set<AnyCancellable>()
    
    var dataSource: UICollectionViewDiffableDataSource<Categories, MovieItem>! = nil
    var currentSnapshot: NSDiffableDataSourceSnapshot<Categories, MovieItem>! = nil
    
    public let didTransitionSubject = PassthroughSubject<Void, Never>()

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
        
        viewModel.$error
            .dropFirst()
            .sink { [weak self] errorMessage in
                self?.showError(message: errorMessage)
            }
            .store(in: &subscriptions)
        
        viewModel.$popularMovies
            .sink { [weak self] movies in
                guard let self = self else { return }
                self.currentSnapshot.appendItems(movies ?? [], toSection: .popularMovies)
                self.dataSource.apply(self.currentSnapshot, animatingDifferences: true)
            }
            .store(in: &subscriptions)
        
        viewModel.$upcomingMovies
            .sink { [weak self] movies in
                guard let self = self else { return }
                self.currentSnapshot.appendItems(movies ?? [], toSection: .upcomingMovies)
                self.dataSource.apply(self.currentSnapshot, animatingDifferences: true)
            }
            .store(in: &subscriptions)

        viewModel.$topRatedMovies
            .sink { [weak self] movies in
                guard let self = self else { return }
                self.currentSnapshot.appendItems(movies ?? [], toSection: .topRatedMovies)
                self.dataSource.apply(self.currentSnapshot, animatingDifferences: true)
            }
            .store(in: &subscriptions)

        viewModel.$nowPlayingMovies
            .sink { [weak self] movies in
                guard let self = self else { return }
                self.currentSnapshot.appendItems(movies ?? [], toSection: .nowPlayingMovies)
                self.dataSource.apply(self.currentSnapshot, animatingDifferences: true)
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
        collectionView.delegate = self
        view.addSubview(collectionView)
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
 
            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.425), heightDimension: .fractionalWidth(0.425  * Constants.posterAspectRatio ) )
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
        let position = point.x
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

        if position > (contentSize + 20 - environment.container.contentSize.width) {
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

extension MainViewController: ListsViewControllerDelegate {
    func didDismiss(with message: String) {
        view.addSubview(popUpWindow)
        popUpWindow.message = message
        popUpWindow.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 60).isActive = true
        popUpWindow.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        popUpWindow.heightAnchor.constraint(equalToConstant: 100).isActive = true
        popUpWindow.widthAnchor.constraint(equalToConstant: view.frame.width - 64).isActive = true
                
        let distance = (view.frame.height) / 2.0
        popUpWindow.transform = CGAffineTransform(translationX: 0, y: distance)
        popUpWindow.alpha = 1
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.3) {
            self.popUpWindow.alpha = 1
            self.popUpWindow.transform = CGAffineTransform.identity
        }
        
        Timer.publish(every: 1.3, on: .main, in: .common)
            .autoconnect()
            .first()
            .sink { _ in
                UIView.animate(withDuration: 0.5) {
                    self.popUpWindow.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
                    self.popUpWindow.alpha = 0
                } completion: { _ in
                    self.popUpWindow.removeFromSuperview()
                }
            }
            .store(in: &subscriptions)
        
    }
}

// MARK: - UICollectionViewDelegate

extension MainViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! MainCollectionViewCell
        let section = currentSnapshot.sectionIdentifiers[indexPath.section]
        let item = currentSnapshot.itemIdentifiers(inSection: section)[indexPath.item]
        let id = item.id
        let detailViewController = DetailViewController(movieId: id, moviePoster: cell.posterImageView.image ?? GlobalConstants.defaultImage)
        navigationController?.present(detailViewController, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemsAt indexPaths: [IndexPath], point: CGPoint) -> UIContextMenuConfiguration? {
        
        guard !indexPaths.isEmpty else { return nil }
        let indexPath = indexPaths[0]
        
        guard let cell = collectionView.cellForItem(at: indexPath) as? MainCollectionViewCell else { return nil }
        guard let section = Categories.intToCategories(section: indexPath.section) else { return nil }
        let itemInfo = self.currentSnapshot.itemIdentifiers(inSection: section)[indexPath.item]
        
        let config = UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { [weak self] _ in
            guard let self = self else { return nil }
            let menu: UIMenu?
            
            
            // MARK: - share action
            let share = UIAction(
                title: "Share",
                state: .off
            ) { _ in }
            
            // MARK: - add/remove movies action
            
            let listsInWhichMovieIsStored = self.coreDataManager.fetchListsInWhichMovieIsStored(movieId: itemInfo.id)
            
            let listsViewController = ListsViewController(
                movieTitle: itemInfo.title,
                movieImage: cell.posterImageView.image,
                movieId: itemInfo.id,
                delegate: self
            )
            
            
            let UInavVC = UINavigationController(rootViewController: listsViewController)
            if let sheet = UInavVC.presentationController as? UISheetPresentationController {
                sheet.detents = [.medium(), .large()]
                sheet.largestUndimmedDetentIdentifier = .medium
                sheet.prefersGrabberVisible = true
            }
            
            let addToList = UIAction(
                title: "Add To List",
                image: UIImage(systemName: "plus"),
                state: .off
            ) { _ in
                listsViewController.type = .addMovie
                self.present(UInavVC, animated: true)
            }
            
            let removeFromLists = UIAction(
                title: "Remove From Lists",
                image: UIImage(systemName: "delete.left"),
                state: .off
            ) { _ in
                listsViewController.type = .deleteMovie
                self.present(UInavVC, animated: true)
            }

            if !listsInWhichMovieIsStored.isEmpty {
                menu = UIMenu(title: "Actions", identifier: nil, options: UIMenu.Options.displayInline, children: [share, addToList, removeFromLists])
            } else {
                menu = UIMenu(title: "Actions", identifier: nil, options: UIMenu.Options.displayInline, children: [share, addToList])
            }
            
            return menu

        }
        
        
        return config
        
    }
   
}

