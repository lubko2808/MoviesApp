//
//  SearchViewController.swift
//  MoviesApp
//
//  Created by Любомир  Чорняк on 22.08.2023.
//

import UIKit
import SnapKit
import Combine

class SearchViewController: UIViewController {
    
    enum Section: Int, Hashable {
        case genres
        case movies
    }
    
    struct Item: Hashable {
        
        let genre: Genre?
        let movie: MovieInfo?
        
        init(genre: Genre? = nil, movie: MovieInfo? = nil) {
            self.genre = genre
            self.movie = movie
        }
    }
    
    let searchController = UISearchController(searchResultsController: nil)
    
    lazy private var collectionView: UICollectionView = {
        let collectionViewLayout = UICollectionViewLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: collectionViewLayout)
        collectionView.backgroundColor = .none
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.delegate = self
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    
    private let activityIndicatorView: UIActivityIndicatorView = {
        let activityIndicatorView = UIActivityIndicatorView(style: .large)
        activityIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        return activityIndicatorView
    }()
    
    private var selectedGenre: IndexPath?
    
    var dataSource: UICollectionViewDiffableDataSource<Section, Item>! = nil
    var currentSnapshot: NSDiffableDataSourceSnapshot<Section, Item>! = nil
    private var subscriptions = Set<AnyCancellable>()
    private var searchParametersSubscriptions = Set<AnyCancellable>()
    
    private let viewModel = SearchViewModel(networkManager: NetworkManager())
    private var isCellAppearedFirstTime = true
    private var timer: Timer?
    private var shouldAddMoreMovies = false
    private var isMoviesCountEqualToZero = true
    
    // MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()

        bindToViewModel()
        configureDataSource()
        setupViews()
        setConstraints()

    }
    
    private func bindToViewModel() {
        viewModel.$error
            .dropFirst()
            .sink { [weak self] errorMessage in
                self?.showError(message: errorMessage)
            }
            .store(in: &subscriptions)
        
        viewModel.$movies
            .dropFirst()
            .sink { [weak self] movies in
                guard let self = self else { return }
                
                // original 'movies' is the constant
                var movies = movies
                
                self.activityIndicatorView.stopAnimating()
                
                if movies.isEmpty {
                    self.isMoviesCountEqualToZero = true
                    //self.currentSnapshot.deleteItems(self.currentSnapshot.itemIdentifiers(inSection: .movies))
                    self.currentSnapshot.appendItems([Item()], toSection: .movies)
                    self.dataSource.apply(self.currentSnapshot, animatingDifferences: true)
                    self.currentSnapshot.deleteItems([Item()])
                    return
                }
                
                if !self.shouldAddMoreMovies {
                    self.currentSnapshot.deleteItems(self.currentSnapshot.itemIdentifiers(inSection: .movies))
   
                }
                self.isMoviesCountEqualToZero = false
                
                // delete possible duplicates
                movies.forEach { movie in
                    let count = movies.filter {$0 == movie}.count
                    if count > 1 {
                        movies.removeAll {$0 == movie}
                        movies.append(movie)
                    }
                   
                    
                    if self.currentSnapshot.itemIdentifiers.contains(where: {$0 == movie}) {
                        movies.removeAll(where: {$0 == movie})
                    }
                }
            
                self.currentSnapshot.appendItems(movies, toSection: .movies)
                self.dataSource.apply(self.currentSnapshot, animatingDifferences: true)
            }
            .store(in: &subscriptions)
    }
    
    private func setupViews() {
        view.backgroundColor = .systemBackground

        collectionView.collectionViewLayout = createLayout()
        view.addSubview(collectionView)
        view.addSubview(activityIndicatorView)
        
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Items"
        
        let advancedSearchButton = UIButton(type: .custom)
        advancedSearchButton.setTitle("Advanced Search", for: .normal)
        advancedSearchButton.setTitleColor(.blue, for: .normal)
        advancedSearchButton.addTarget(self, action: #selector(customButtonTapped), for: .touchUpInside)
        let advancedSearchBarButton = UIBarButtonItem(customView: advancedSearchButton)

        navigationItem.rightBarButtonItem = advancedSearchBarButton
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
    }
    
    private func setConstraints() {
        collectionView.snp.makeConstraints { make in
            make.leading.trailing.top.bottom.equalToSuperview()
        }
        
        activityIndicatorView.snp.makeConstraints { make in
            make.centerX.centerY.equalToSuperview()
            make.height.width.equalTo(60)
        }
    }
}

// MARK: - Helpers
extension SearchViewController {
    private func showError(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        print("showError: \(Thread.current)")
        present(alert, animated: true, completion: nil)
    }
}

// MARK: - @objc
extension SearchViewController {
    @objc func customButtonTapped() {
        let advancedSearchViewController = AdvancedSearchViewController()
        advancedSearchViewController.configure(with: viewModel.rating,
                                               totalVotes: viewModel.totalVotes,
                                               decade: viewModel.decade,
                                               year: viewModel.year,
                                               includeAdult: viewModel.includeAdult,
                                               primaryLanguage: viewModel.primaryLanguage)
        searchParametersSubscriptions.removeAll()
        
        advancedSearchViewController.didDismissPublisher
            .sink { _ in
                self.viewModel.cancelTask()
            }
            .store(in: &searchParametersSubscriptions)
        
        advancedSearchViewController.ratingPublisher
            .assign(to: \.rating, on: viewModel)
            .store(in: &searchParametersSubscriptions)
        
        advancedSearchViewController.totalVotesPublisher
            .assign(to: \.totalVotes, on: viewModel)
            .store(in: &searchParametersSubscriptions)
        
        advancedSearchViewController.decadePublisher
            .assign(to: \.decade, on: viewModel)
            .store(in: &searchParametersSubscriptions)
        
        advancedSearchViewController.yearPublisher
            .assign(to: \.year, on: viewModel)
            .store(in: &searchParametersSubscriptions)
        
        advancedSearchViewController.includeAdultPublisher
            .assign(to: \.includeAdult, on: viewModel)
            .store(in: &searchParametersSubscriptions)
        
        advancedSearchViewController.primaryLanguagePublisher
            .assign(to: \.primaryLanguage, on: viewModel)
            .store(in: &searchParametersSubscriptions)
            
        let destinationVC = UINavigationController(rootViewController: advancedSearchViewController)
        present(destinationVC, animated: true)
    }
}

// MARK: - Data Source
extension SearchViewController {
    private func createGenreCellRegistration() -> UICollectionView.CellRegistration<GenreCollectionViewCell, Genre> {
        UICollectionView.CellRegistration<GenreCollectionViewCell, Genre> { (cell, indexPath, genre) in
            if self.isCellAppearedFirstTime && indexPath.item == 0 {
                self.selectedGenre = indexPath
                cell.isCellSelected = true
                self.isCellAppearedFirstTime = false
            } else if indexPath != self.selectedGenre {
                cell.isCellSelected = false
            } else {
                cell.isCellSelected = true
            }
            cell.configure(with: genre)
        }
    }
    
    private func createMovieCellRegistration() -> UICollectionView.CellRegistration<MainCollectionViewCell, MovieInfo> {
        UICollectionView.CellRegistration<MainCollectionViewCell, MovieInfo> { (cell, indexPath, movie) in
            cell.configure(with: movie.posterPath, title: movie.title)
            
        }
    }
    
    private func createEmptyDataCellRegistration() -> UICollectionView.CellRegistration<EmptyDataCollectionViewCell, Void> {
        UICollectionView.CellRegistration<EmptyDataCollectionViewCell, Void> { cell, indexPath, _ in
            
        }
    }
    
    private func configureDataSource() {
        let genreCellRegistration = createGenreCellRegistration()
        let movieCellRegistration = createMovieCellRegistration()
        let emptyDataCellRegistration = createEmptyDataCellRegistration()
        
        dataSource = UICollectionViewDiffableDataSource(collectionView: collectionView) {
            (collectionView: UICollectionView, indexPath: IndexPath, item: Item) -> UICollectionViewCell? in
            guard let section = Section(rawValue: indexPath.section) else { return nil }
            switch section {
            case .genres:
                return collectionView.dequeueConfiguredReusableCell(using: genreCellRegistration, for: indexPath, item: item.genre)
            case .movies:
                if self.isMoviesCountEqualToZero {
                    return collectionView.dequeueConfiguredReusableCell(using: emptyDataCellRegistration, for: indexPath, item: () )
                } else {
                    return collectionView.dequeueConfiguredReusableCell(using: movieCellRegistration, for: indexPath, item: item.movie)
                }
            }
        }
        
        let sections: [Section] = [.genres, .movies]
        currentSnapshot = NSDiffableDataSourceSnapshot<Section, Item>()
        currentSnapshot.appendSections(sections)
        var genres: [Item] = []
        Genre.allCases.forEach { genre in
            genres.append(Item(genre: genre))
        }
        currentSnapshot.appendItems(genres, toSection: .genres)
        
        currentSnapshot.appendItems([Item()], toSection: .movies)
        dataSource.apply(currentSnapshot, animatingDifferences: true)
        currentSnapshot.deleteItems([Item()])
    }
}

// MARK: - createLayout
extension SearchViewController {
    private func createLayout() -> UICollectionViewCompositionalLayout {
       
        let sectionProvider = { (sectionIndex: Int, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
            
            guard let sectionKind = Section(rawValue: sectionIndex) else { return nil }
            let section: NSCollectionLayoutSection
            
            switch sectionKind {
            case .genres:
                let itemSize = NSCollectionLayoutSize(widthDimension: .estimated(100), heightDimension: .fractionalHeight(1.0))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                let groupSize = NSCollectionLayoutSize(widthDimension: .estimated(100), heightDimension: .fractionalHeight(0.06))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
                section = NSCollectionLayoutSection(group: group)
                section.orthogonalScrollingBehavior = .continuous
                section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10)
            case .movies:
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                
                if self.isMoviesCountEqualToZero {
                    let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(0.5))
                    let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
                    section = NSCollectionLayoutSection(group: group)
                    section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10)
                } else {
                    let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalWidth(1  * GlobalConstants.posterAspectRatio ))
                    let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
                    section = NSCollectionLayoutSection(group: group)
                    section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 50, bottom: 10, trailing: 50)
                }
            }
            
            section.interGroupSpacing = 10
            return section
        }
        
        let config = UICollectionViewCompositionalLayoutConfiguration()
        config.interSectionSpacing = 20
        let layout = UICollectionViewCompositionalLayout(sectionProvider: sectionProvider, configuration: config)
        return layout
    }
}

// MARK: - UICollectionViewDelegate
extension SearchViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // genre
        if indexPath.section == 0 {
            let selectedCell = collectionView.cellForItem(at: selectedGenre ?? IndexPath()) as? GenreCollectionViewCell
            
            guard let cellToSelect = collectionView.cellForItem(at: indexPath) as? GenreCollectionViewCell else { return }

            selectedCell?.isCellSelected = false
            cellToSelect.isCellSelected = true
            selectedGenre = indexPath
            
            //guard !viewModel.query.isEmpty else { return }
            viewModel.genre = Genre.allCases[selectedGenre?.item ?? 0]
            shouldAddMoreMovies = false
            currentSnapshot.deleteItems(self.currentSnapshot.itemIdentifiers(inSection: .movies))
            dataSource.apply(currentSnapshot, animatingDifferences: true)
            activityIndicatorView.startAnimating()
            viewModel.searchMovies(shouldStartFromBeginning: true)
        // movie
        } else {
            guard let cell = collectionView.cellForItem(at: indexPath) as? MainCollectionViewCell else { return }
            let item = currentSnapshot.itemIdentifiers(inSection: .movies)[indexPath.item]
            guard let id = item.movie?.id else { return }
            let detailViewController = DetailViewController(movieId: id, moviePoster: cell.posterImageView.image ?? GlobalConstants.defaultImage)
            present(detailViewController, animated: true)
        }
    }
}

// MARK: - UIScrollViewDelegate
extension SearchViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let screenHeight = scrollView.frame.size.height

        if offsetY > contentHeight - screenHeight {
            if !viewModel.isPaginating {
                shouldAddMoreMovies = true
                viewModel.searchMovies(shouldStartFromBeginning: false)
            }
        }
    }
}

// MARK: - UISearchResultsUpdating
extension SearchViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        viewModel.query = searchController.searchBar.text ?? ""
        
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 0.6, repeats: false) { timer in
            self.shouldAddMoreMovies = false
            let visibleCells = self.collectionView.visibleCells
            self.currentSnapshot.deleteItems(self.currentSnapshot.itemIdentifiers(inSection: .movies))
            self.dataSource.apply(self.currentSnapshot, animatingDifferences: true)
            self.activityIndicatorView.startAnimating()
            self.viewModel.searchMovies(shouldStartFromBeginning: true)
        }
    }
}


