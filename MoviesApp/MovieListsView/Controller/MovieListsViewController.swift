//
//  FavoritesViewController.swift
//  MoviesApp
//
//  Created by Любомир  Чорняк on 22.08.2023.
//

import UIKit
import SnapKit
import Combine

class MovieListsViewController: UIViewController {
    
    enum Section: Int, Hashable {
        case lists
        case movies
    }
    
    struct Item: Hashable {
        let movie: Movie?
        let lists: [MovieList]?
        let message: String?
        
        init(movie: Movie? = nil, lists: [MovieList]? = nil, message: String? = nil) {
            self.movie = movie
            self.lists = lists
            self.message = message
        }
    }
    
    // MARK: - Properties
    var currentlySelectedList: String? = nil
    private var isListsCountEqualToZero = Bool()
    private var isMoviesInCurrentListPresent = Bool()
    private var moviesToDelete: Set<IndexPath> = []
    private var areCellsInSelectionState: Bool = false
    private var subscriptions = Set<AnyCancellable>()
    
    var dataSource: UICollectionViewDiffableDataSource<Section, Item>! = nil
    var currentSnapshot: NSDiffableDataSourceSnapshot<Section, Item>! = nil
    
    private let coreDataManager = CoreDataManager.shared
    
    var tapGestureRecognizer: UITapGestureRecognizer?
    
    private enum Constants {
        static let titleElementKind = "title-element-kind"
        static let posterAspectRatio: CGFloat = 3 / 2
        static let interGroupSpacing: CGFloat = 15
        static let sectionContentInset: CGFloat = 15
        static let deleteButtonHeight: CGFloat = 44
    }
    
    // MARK: - UI Properties
    private let collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewLayout())
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    
    private let deleteButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .white
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowRadius = 5
        button.layer.shadowOffset = CGSize(width: 5, height: 5)
        button.layer.shadowOpacity = 1
        button.layer.cornerRadius = 20
        button.isHidden = true
        button.setTitle("Delete", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK: - lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        setupViews()
        setConstraints()
        configureDataSource()
        getLists()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        refreshData()
    }

    // MARK: - Other
    private func setupViews() {
        view.addSubview(collectionView)
        collectionView.collectionViewLayout = createLayout()
        collectionView.delegate = self
        
        view.addSubview(deleteButton)
        deleteButton.addTarget(self, action: #selector(deleteButtonTapped), for: .touchUpInside)
    }

    private func setConstraints() {
        collectionView.snp.makeConstraints { make in
            make.top.trailing.leading.bottom.equalToSuperview()
        }
        
        deleteButton.snp.makeConstraints { make in
            make.width.equalTo(100)
            make.height.equalTo(Constants.deleteButtonHeight)
            make.centerX.equalToSuperview()
            make.top.equalTo(view.snp.bottom)
        }
        
    }
    
    private func getLists() {
        var items = [Item]()
        
        let lists = coreDataManager.fetchMovieLists()
        isListsCountEqualToZero = lists.isEmpty ? true : false
        if lists.isEmpty {
            items = [Item(message: "There are no lists")]
        } else {
            items = [Item(lists: lists)]
        }
        currentSnapshot.appendItems(items, toSection: .lists)
        dataSource.apply(currentSnapshot)
    }
    
    private func refreshData() {
        guard let currentlySelectedList else { return }
        guard let movies = self.coreDataManager.fetchMovies(in: currentlySelectedList) else { return }
        guard !movies.isEmpty else { return }
        isMoviesInCurrentListPresent = movies.isEmpty ? false : true
        let items = movies.map { Item(movie: $0) }
        self.currentSnapshot.deleteSections([.movies])
        self.currentSnapshot.appendSections([.movies])
        self.currentSnapshot.appendItems(items, toSection: .movies)
        self.dataSource.apply(self.currentSnapshot)
    }
}

// MARK: - Helpers
extension MovieListsViewController {
    private func getVisibleMovieCells() -> [MovieCollectionViewCell] {
        let visibleCells = collectionView.visibleCells.compactMap { cell -> MovieCollectionViewCell? in
            guard let cell = cell as? MovieCollectionViewCell else { return nil }
            let indexPath = collectionView.indexPath(for: cell)
            if indexPath?.section == 0 { return nil }
            return cell
        }
        return visibleCells
    }
    
    private func bringUpDeleteButton() {
        deleteButton.isHidden = false
        UIView.animate(withDuration: 0.15) {
            self.deleteButton.snp.updateConstraints { make in
                let offset = -GlobalConstants.tabBarHeight - GlobalConstants.tabBarInset - Constants.deleteButtonHeight - 18
                make.top.equalTo(self.view.snp.bottom).offset(offset)
            }
            
            self.view.layoutIfNeeded()
        }
    }
    
    private func hideDeleteButton() {
        UIView.animate(withDuration: 0.15) {
            self.deleteButton.snp.updateConstraints { make in
                make.top.equalTo(self.view.snp.bottom)
            }
            self.view.layoutIfNeeded()
        } completion: { _ in
            self.deleteButton.isHidden = true
        }
    }
}

// MARK: - Action handlers
extension MovieListsViewController {
    
    @objc func deleteButtonTapped() {
        for index in moviesToDelete.map({$0.row}) {
            let item = self.currentSnapshot.itemIdentifiers(inSection: .movies)[index]
            coreDataManager.deleteMovieFromLists(listNames: [currentlySelectedList ?? ""], movieId: Int(item.movie?.id ?? 0))
        }
        self.currentSnapshot.deleteSections([.movies])
        self.currentSnapshot.appendSections([.movies])
        if let movies = coreDataManager.fetchMovies(in: currentlySelectedList ?? "") {
            self.currentSnapshot.appendItems(movies.map{Item(movie: $0)})
            self.dataSource.apply(currentSnapshot)
        }
        
        let visibleCells = getVisibleMovieCells()
        for cell in visibleCells {
            cell.selectedToDeleteImageView.isHidden = true
            UIView.animate(withDuration: 0.2) {
                cell.transform = .identity
            }
        }
        areCellsInSelectionState = false
        hideDeleteButton()
        
    }
    
    @objc func handlePressGesture(_ gestureRecognizer: UILongPressGestureRecognizer) {
        guard let selectedCell = gestureRecognizer.view as? MovieCollectionViewCell, let selectedIndexPath = collectionView.indexPath(for: selectedCell) else {
            return
        }
        
        guard selectedIndexPath.section == 1 else { return }
        
        let visibleCells = getVisibleMovieCells()

        if gestureRecognizer.state == .began {
            bringUpDeleteButton()
            
            areCellsInSelectionState = true
            
            for cell in visibleCells {
                cell.selectedToDeleteImageView.isHidden = false
                cell.selectedToDeleteImageView.image = UIImage.circleSymbol
                UIView.animate(withDuration: 0.2) {
                    cell.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
                }
            }
            
            selectedCell.selectedToDeleteImageView.image = UIImage.checkmarkSymbol
            moviesToDelete.insert(selectedIndexPath)
        }
    }
}

// MARK: - UICollectionViewDelegate
extension MovieListsViewController: UICollectionViewDelegate {
    
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let cell = cell as? MovieCollectionViewCell, indexPath.section == 1 else { return }
        if self.areCellsInSelectionState {
            cell.selectedToDeleteImageView.isHidden = false
            cell.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
            
            if self.moviesToDelete.contains(indexPath) {
                cell.selectedToDeleteImageView.image = UIImage.checkmarkSymbol
            } else {
                cell.selectedToDeleteImageView.image = UIImage.circleSymbol
            }
        } else {
            cell.selectedToDeleteImageView.isHidden = true
            cell.transform = .identity
        }
        
       
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? MovieCollectionViewCell else { return }
        
        if self.areCellsInSelectionState {
            if moviesToDelete.contains(indexPath) {
                cell.selectedToDeleteImageView.image = UIImage.circleSymbol
                moviesToDelete.remove(indexPath)
            } else {
                cell.selectedToDeleteImageView.image = UIImage.checkmarkSymbol
                moviesToDelete.insert(indexPath)
            }
            
            if moviesToDelete.isEmpty {
                let visibleCells = getVisibleMovieCells()
                for cell in visibleCells {
                    cell.selectedToDeleteImageView.isHidden = true
                    UIView.animate(withDuration: 0.2) {
                        cell.transform = .identity
                    }
                }
                hideDeleteButton()
                areCellsInSelectionState = false
            }
        }
    }
}

// MARK: - Data Source
extension MovieListsViewController {
    
    private func createListsContainerCellRegistration() -> UICollectionView.CellRegistration<MovieListsContainerCell, [MovieList]> {
        UICollectionView.CellRegistration<MovieListsContainerCell, [MovieList]> { (cell, indexPath, lists) in
            cell.lists = lists.map({ $0.name })
            
            self.subscriptions.removeAll()
            
            cell.listSelectedSubject
                .sink { listName in
                    self.areCellsInSelectionState = false
                    self.hideDeleteButton()
                    let visibleCells = self.getVisibleMovieCells()
                    for cell in visibleCells {
                        cell.selectedToDeleteImageView.isHidden = true
                        cell.transform = .identity
                    }
                    
                    self.currentlySelectedList = listName
                    guard let movies = self.coreDataManager.fetchMovies(in: listName) else { return }
                    self.isMoviesInCurrentListPresent = movies.isEmpty ? false : true
                    let items = movies.map { Item(movie: $0) }

                    self.currentSnapshot.deleteSections([.movies])
                    self.currentSnapshot.appendSections([.movies])
                    if !items.isEmpty {
                        self.currentSnapshot.appendItems(items, toSection: .movies)
                    } else {
                        let item = Item(message: "The list is empty")
                        self.currentSnapshot.appendItems([item], toSection: .movies)
                    }
                    self.dataSource.apply(self.currentSnapshot)
                }
                .store(in: &self.subscriptions)
             
            
            cell.listTappedToDeleteSubject
                .sink { index in
                    print("index: \(index)")
                    print("subscriptions.count: \(self.subscriptions.count)")
                    let item = self.currentSnapshot.itemIdentifiers(inSection: .lists)[0]
                    self.currentSnapshot.deleteItems([item])
                    var listToDelete = String()
                    if let lists = item.lists {
                        listToDelete = lists[index].name
                        self.coreDataManager.deleteMovieList(lists[index])
                    }

                    if self.currentlySelectedList == listToDelete {
                        self.currentSnapshot.deleteSections([.movies])
                        self.currentSnapshot.appendSections([.movies])
                        self.currentlySelectedList = nil
                    }
                    
                    let movieLists = self.coreDataManager.fetchMovieLists()
                    if movieLists.isEmpty {
                        self.isListsCountEqualToZero = true
                        self.currentSnapshot.appendItems([Item(message: "There are no lists")], toSection: .lists)
                    } else {
                        self.currentSnapshot.appendItems([Item(lists: movieLists)], toSection: .lists)
                    }
                    
                    self.dataSource.apply(self.currentSnapshot)
                }
                .store(in: &self.subscriptions)
             
        }
    }
    
    private func createMovieCellRegistration() -> UICollectionView.CellRegistration<MovieCollectionViewCell, Movie> {
        UICollectionView.CellRegistration<MovieCollectionViewCell, Movie> { (cell, indexPath, movie) in
            cell.configure(with: UIImage(data: movie.poster ?? Data()))
            let longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(self.handlePressGesture(_:)))
            cell.addGestureRecognizer(longPressGestureRecognizer)
        }
    }

    private func createDefaultCollectionCellRegistration() -> UICollectionView.CellRegistration<DefaultCollectionViewCell, String> {
        UICollectionView.CellRegistration<DefaultCollectionViewCell, String> { (cell, indexPath, message) in
            cell.configure(with: message)
        }
    }
    
    private func configureDataSource() {
        let listsContainerCellRegistration = createListsContainerCellRegistration()
        let movieCellRegistration = createMovieCellRegistration()
        let defaultCellRegistration = createDefaultCollectionCellRegistration()
        
        dataSource = UICollectionViewDiffableDataSource(collectionView: collectionView) {
            (collectionView: UICollectionView, indexPath: IndexPath, item: Item) -> UICollectionViewCell? in
            guard let section = Section(rawValue: indexPath.section) else { return nil }
            switch section {
            case .lists:
                if self.isListsCountEqualToZero {
                    return collectionView.dequeueConfiguredReusableCell(using: defaultCellRegistration, for: indexPath, item: item.message)
                } else {
                    return collectionView.dequeueConfiguredReusableCell(using: listsContainerCellRegistration, for: indexPath, item: item.lists)
                }
            case .movies:
                if !self.isMoviesInCurrentListPresent {
                    return collectionView.dequeueConfiguredReusableCell(using: defaultCellRegistration, for: indexPath, item: item.message)
                } else {
                    return collectionView.dequeueConfiguredReusableCell(using: movieCellRegistration, for: indexPath, item: item.movie)
                }
            }
        }
        
        let movieListsSupplementaryRegistration = UICollectionView.SupplementaryRegistration<MovieListsSectionTitle>(elementKind: Constants.titleElementKind) { _, _, _ in }
        
        let moviesSupplementaryRegistration = UICollectionView.SupplementaryRegistration<MoviesSectionTitle>(elementKind: Constants.titleElementKind) { _, _, _ in }
        
        dataSource.supplementaryViewProvider = { view, kind, index in
            if index.section == 0 {
                let movieListsSectionTitle = self.collectionView.dequeueConfiguredReusableSupplementary(using: movieListsSupplementaryRegistration, for: index)
                movieListsSectionTitle.delegate = self
                return movieListsSectionTitle;
            } else {
                let moviesSectionTitle = self.collectionView.dequeueConfiguredReusableSupplementary(using: moviesSupplementaryRegistration, for: index)
              
                return moviesSectionTitle
            }
        }

        let sections: [Section]  = [.lists, .movies]
        currentSnapshot = NSDiffableDataSourceSnapshot<Section, Item>()
        currentSnapshot.appendSections(sections)
        dataSource.apply(currentSnapshot, animatingDifferences: false)
        
        
    }
    
}

// MARK: - Collection View Layout
extension MovieListsViewController {
    
    private func createLayout() -> UICollectionViewCompositionalLayout {
        
        let sectionProvider = { (sectionIndex: Int, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
            
            guard let sectionKind = Section(rawValue: sectionIndex) else { return nil }
            let section: NSCollectionLayoutSection
            
            switch sectionKind {
            case .lists:
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(200))

                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(200))

                let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
                section = NSCollectionLayoutSection(group: group)
                section.contentInsets = NSDirectionalEdgeInsets(top: 20, leading: 10, bottom: 10, trailing: 10)
            case .movies:
                
                if self.isMoviesInCurrentListPresent {
                    let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.35),
                                                         heightDimension: .fractionalHeight( 1 ))
                    let item = NSCollectionLayoutItem(layoutSize: itemSize)
                    item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 5, bottom: 0, trailing: 5)

                    let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                          heightDimension: .fractionalWidth(0.35  * Constants.posterAspectRatio ))
                    let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: 3)

                    section = NSCollectionLayoutSection(group: group)
                    section.interGroupSpacing = Constants.interGroupSpacing
                    section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: Constants.sectionContentInset, bottom: 0, trailing: Constants.sectionContentInset)
                } else {
                    let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                                          heightDimension: .fractionalHeight(1))
                    let item = NSCollectionLayoutItem(layoutSize: itemSize)
                    let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(0.25))
                    let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
                    section = NSCollectionLayoutSection(group: group)
                    section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: Constants.sectionContentInset, bottom: 0, trailing: Constants.sectionContentInset)
                }
                
        
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
    
}

// MARK: - MovieListsSectionTitleProtocol
extension MovieListsViewController: MovieListsSectionTitleProtocol {
    func didTapAddListButton(_ listName: String) -> String? {
        if listName.isEmpty {
            return "List name is empty"
        } else if coreDataManager.isListInStorage(listName) {
            return "List with this name already exists"
        } else {
            removeTapGesture()
            let initialLists = coreDataManager.fetchMovieLists()
            coreDataManager.createMovieList(name: listName)
            let currentLists = coreDataManager.fetchMovieLists()
            if isListsCountEqualToZero {
                isListsCountEqualToZero = false
                currentSnapshot.deleteSections([.lists, .movies])
                currentSnapshot.appendSections([.lists, .movies])
            } else {
                let initialListsItem = [Item(lists: initialLists)]
                currentSnapshot.deleteItems(initialListsItem)

            }
            let currentListsItem = [Item(lists: currentLists)]
            currentSnapshot.appendItems(currentListsItem, toSection: .lists)
            dataSource.apply(currentSnapshot, animatingDifferences: false)
            return nil
        }
    }
    
    func keyboardIsInvoked() {
        hideKeyboardWhenTappedAround()
    }
}

// MARK: - Keyboard Dismissal
extension MovieListsViewController {
    
    func hideKeyboardWhenTappedAround() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGestureRecognizer = tap
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
        removeTapGesture()
    }
    
    func removeTapGesture() {
        if let tapGestureRecognizer = tapGestureRecognizer {
            view.removeGestureRecognizer(tapGestureRecognizer)
        }
    }
    
}
