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
    
    public var didTapMovieCell: ((Int, UIImage) -> Void)?
    public var didTapAdvancedSearch: ((AdvancedSearchModel) -> Void)?
    public var onListActionTapped: ((_ title: String, _ poster: UIImage?, _ id: Int, _ type: ActionType) -> Void)?

    let searchController = UISearchController(searchResultsController: nil)
    private let popUpWindow = PopUpWindow(frame: .zero)
    private let collectionView = SearchScreenCollectionView()
    private let activityIndicatorView = UIActivityIndicatorView(style: .large)
    
    private var subscriptions = Set<AnyCancellable>()
    
    private let viewModel: SearchViewModelProtocol
    private var timer: Timer?
    private var shouldAddMoreMovies = false
    
    init(viewModel: SearchViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()

        bindToViewModel()
        setupViews()
        setConstraints()
    }
    
    private func bindToViewModel() {
        viewModel.errorPublisher
            .dropFirst()
            .sink { [weak self] errorMessage in
                guard let self = self else { return }
                self.showError(with: errorMessage)
                self.collectionView.makeEmptyState()
            }
            .store(in: &subscriptions)
        
        viewModel.moviesPublisher
            .dropFirst()
            .sink { [weak self] movies in
                guard let self = self else { return }
                
                self.activityIndicatorView.stopAnimating()
            
                if movies.isEmpty {
                    self.collectionView.makeEmptyState()
                    return
                }
                
                if !self.shouldAddMoreMovies {
                    self.collectionView.deleteAllItemsInMoviesSection()
                }
                
                self.collectionView.appendMovies(movies: movies)
                
            }
            .store(in: &subscriptions)
    }
    
    private func setupViews() {
        view.backgroundColor = .systemBackground

        collectionView.delegate = self
        activityIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(collectionView)
        view.addSubview(activityIndicatorView)
        
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Movies"
        
        let advancedSearchButton = UIButton(type: .custom)
        advancedSearchButton.setTitle("Advanced Search", for: .normal)
        advancedSearchButton.setTitleColor(.blue, for: .normal)
        advancedSearchButton.addTarget(self, action: #selector(advancedSearchButtonTapped), for: .touchUpInside)
        let advancedSearchBarButton = UIBarButtonItem(customView: advancedSearchButton)
        
        title = "Search"
        navigationController?.navigationBar.prefersLargeTitles = true

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

// MARK: - @objc
extension SearchViewController {
    
    public func setSearchParameters(parameters: AdvancedSearchModel) {
        viewModel.rating = parameters.rating
        viewModel.totalVotes = parameters.totalVotes
        viewModel.decade = parameters.decade
        viewModel.year = parameters.year
        viewModel.includeAdult = parameters.includeAdult
        viewModel.primaryLanguage = parameters.primaryLanguage
    }
    
    @objc func advancedSearchButtonTapped() {
        didTapAdvancedSearch?(AdvancedSearchModel(rating: viewModel.rating,
                                                  totalVotes: viewModel.totalVotes,
                                                  decade: viewModel.decade,
                                                  year: viewModel.year,
                                                  includeAdult: viewModel.includeAdult,
                                                  primaryLanguage: viewModel.primaryLanguage))
    }
}

 
// MARK: - UICollectionViewDelegate
extension SearchViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // genre
        if indexPath.section == 0 {
            let selectedCell = collectionView.cellForItem(at: self.collectionView.selectedGenre ?? IndexPath()) as? GenreCollectionViewCell
            
            guard let cellToSelect = collectionView.cellForItem(at: indexPath) as? GenreCollectionViewCell else { return }

            selectedCell?.isCellSelected = false
            cellToSelect.isCellSelected = true
            self.collectionView.selectedGenre = indexPath
            
            viewModel.genre = Genre.allCases[self.collectionView.selectedGenre?.item ?? 0]
            shouldAddMoreMovies = false

            if self.collectionView.isMovieContentAvailable {
                self.collectionView.deleteAllItemsInMoviesSection()
            }
            activityIndicatorView.startAnimating()
            viewModel.searchMovies(startFromBeginning: true)
        // movie
        } else {
            guard let cell = collectionView.cellForItem(at: indexPath) as? MainCollectionViewCell else { return }
            guard let movie = self.collectionView.getMovie(for: indexPath) else { return }
            didTapMovieCell?(movie.id, cell.posterImageView.image ?? GlobalConstants.defaultImage)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemsAt indexPaths: [IndexPath], point: CGPoint) -> UIContextMenuConfiguration? {
        
        guard !indexPaths.isEmpty else { return nil }
        let indexPath = indexPaths[0]
        
        guard let cell = collectionView.cellForItem(at: indexPath) as? MainCollectionViewCell else { return nil }
        guard let movie = self.collectionView.getMovie(for: indexPath) else { return nil }
        let listsInWhichMovieIsStored = viewModel.fetchListsInWhichMovieIsStored(moviedId: movie.id)

        let config = UIContextMenuConfiguration(listsInWhichMovieIsStored: listsInWhichMovieIsStored,
                                                title: movie.title,
                                                poster: cell.posterImageView.image,
                                                id: movie.id,
                                                onListActionTapped: onListActionTapped)
        
        return config
        
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
                viewModel.searchMovies(startFromBeginning: false)
            }
        }
    }
}

// MARK: - PopUp
extension SearchViewController {
    
    public func showPopUp(with message: String) {
        popUpWindow.show(with: message, on: view)
    }
    
}

// MARK: - UISearchResultsUpdating
extension SearchViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        viewModel.query = searchController.searchBar.text ?? ""
        
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 0.6, repeats: false) { timer in
            self.shouldAddMoreMovies = false
            if self.collectionView.isMovieContentAvailable || !self.viewModel.query.isEmpty {
                self.collectionView.deleteAllItemsInMoviesSection()
            }
            self.activityIndicatorView.startAnimating()
            self.viewModel.searchMovies(startFromBeginning: true)
          
        }
        
    }
    
}


