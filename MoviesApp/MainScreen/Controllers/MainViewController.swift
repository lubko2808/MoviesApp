//
//  ViewController.swift
//  MoviesApp
//
//  Created by Любомир  Чорняк on 13.08.2023.
//

import UIKit
import Combine


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
    
    typealias Section = MainScreenCollectionView.Section
    typealias Item = MainScreenCollectionView.Item
    private var movies: [Section : [Item] ] = [
        .nowPlayingMovies : [],
        .upcomingMovies : [],
        .topRatedMovies : [],
        .popularMovies : []
    ]

    private let collectionView = MainScreenCollectionView()
    
    private enum Constants {
        static let amountOfMoviesInPage = 20
        static let limitOfMoviesInSection = 200
        static let interGroupSpacing: CGFloat = 15
        static let sectionContentInset: CGFloat = 15
    }
    
    private var subscriptions = Set<AnyCancellable>()
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
                self.showError(with: errorMessage)
            }
            .store(in: &subscriptions)
        
        viewModel.popularMoviesPublisher
            .sink { [weak self] movies in
                self?.movies[.popularMovies]?.append(contentsOf: movies ?? [])
                self?.collectionView.appendMovies(movies ?? [], toSection: .popularMovies)
            }
            .store(in: &subscriptions)
        
        viewModel.upcomingMoviesPublisher
            .sink { [weak self] movies in
                self?.movies[.upcomingMovies]?.append(contentsOf: movies ?? [])
                self?.collectionView.appendMovies(movies ?? [], toSection: .upcomingMovies)
            }
            .store(in: &subscriptions)

        viewModel.topRatedMoviesPublisher
            .sink { [weak self] movies in
                self?.movies[.topRatedMovies]?.append(contentsOf: movies ?? [])
                self?.collectionView.appendMovies(movies ?? [], toSection: .topRatedMovies)
            }
            .store(in: &subscriptions)

        viewModel.nowPlayingMoviesPublisher
            .sink { [weak self] movies in
                self?.movies[.nowPlayingMovies]?.append(contentsOf: movies ?? [])
                self?.collectionView.appendMovies(movies ?? [], toSection: .nowPlayingMovies)
            }
            .store(in: &subscriptions)
    }

    private func setupViews() {
        view.backgroundColor = .systemBackground

        collectionView.delegate = self
        collectionView.horizontalSectionDidScroll = horizontalSectionDidScroll
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.leading.trailing.top.bottom.equalToSuperview()
        }
        
        title = "Main"
        navigationController?.navigationBar.prefersLargeTitles = true
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

    private func setOffset(for section: Section, offset: CGFloat) {
        switch section {
        case .nowPlayingMovies: contentOffsetsX[0] = offset
        case .upcomingMovies: contentOffsetsX[1] = offset
        case .topRatedMovies: contentOffsetsX[2] = offset
        case .popularMovies: contentOffsetsX[3] = offset
        }
    }
}

// MARK: - UICollectionViewDelegate
extension MainViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! MainCollectionViewCell
        guard let section = Section.intToSection(section: indexPath.section) else { return }
        guard let item = movies[section]?[indexPath.item] else { return }
        let id = item.id
        onMovieCellTapped?(id, cell.posterImageView.image ?? GlobalConstants.defaultImage)
    }
    
    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemsAt indexPaths: [IndexPath], point: CGPoint) -> UIContextMenuConfiguration? {
        
        guard !indexPaths.isEmpty else { return nil }
        let indexPath = indexPaths[0]
        
        guard let cell = collectionView.cellForItem(at: indexPath) as? MainCollectionViewCell else { return nil }
        guard let section = Section.intToSection(section: indexPath.section) else { return nil }
        guard let itemInfo = movies[section]?[indexPath.item] else { return nil }
        let listsInWhichMovieIsStored = self.coreDataManager.fetchListsInWhichMovieIsStored(movieId: itemInfo.id)

        let config = UIContextMenuConfiguration(listsInWhichMovieIsStored: listsInWhichMovieIsStored,
                                                title: itemInfo.title,
                                                poster: cell.posterImageView.image,
                                                id: itemInfo.id,
                                                onListActionTapped: onListActionTapped)
        
        return config
        
    }
    
    func horizontalSectionDidScroll(contentOffset: CGFloat, itemWidth: CGFloat, section: Section, environment: NSCollectionLayoutEnvironment) {
        setOffset(for: section, offset: contentOffset)
        guard let amountOfItemsInSection = movies[section]?.count else { return }
        if amountOfItemsInSection > Constants.limitOfMoviesInSection { return }
        if amountOfItemsInSection == 0 { return }
        let contentSize = CGFloat(amountOfItemsInSection) * itemWidth + (2 * Constants.sectionContentInset) + ((CGFloat(amountOfItemsInSection) - 1) * Constants.interGroupSpacing)
        
        if contentOffset > (contentSize + 20 - environment.container.contentSize.width) {
            let newPage = (amountOfItemsInSection / Constants.amountOfMoviesInPage) + 1
            switch section {
            case .nowPlayingMovies:
                guard !self.viewModel.isNowPlayingPaginating else { return }
                self.viewModel.fetchNowPlayingMovies(page: newPage)
            case .upcomingMovies:
                guard !self.viewModel.isUpcomingPaginating else { return }
                self.viewModel.fetchUpcomingMovies(page: newPage)
            case .topRatedMovies:
                guard !self.viewModel.isTopRatedPaginating else { return }
                self.viewModel.fetchTopRatedMovies(page: newPage)
            case .popularMovies:
                guard !self.viewModel.isPopularPaginating else { return }
                self.viewModel.fetchPopularMovies(page: newPage)
            }
        }
    }
    
}



