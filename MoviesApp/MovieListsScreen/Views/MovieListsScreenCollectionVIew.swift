//
//  MovieListsScreenCollectionVIew.swift
//  MoviesApp
//
//  Created by Lubomyr Chorniak on 24.01.2024.
//

import UIKit

class MovieListsScreenCollectionVIew: UICollectionView {
    
    public var isMoviesInCurrentListPresent = false
    
    private var diffDataSource: UICollectionViewDiffableDataSource<Section, Item>
    private var currentSnapshot = NSDiffableDataSourceSnapshot<Section, Item>()
    
    init() {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewLayout())
        diffDataSource = UICollectionViewDiffableDataSource(collectionView: collectionView) { _, _, _ in UICollectionViewCell()}
        
        super.init(frame: .zero, collectionViewLayout: UICollectionViewLayout())
        translatesAutoresizingMaskIntoConstraints = false
        collectionViewLayout = createLayout()
        configureDataSource()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public var onListSelected: ((String) -> ())?
    public var onListTappedToDelete: ((Int) -> ())?
    
    @objc func handlePressGesture(_ gestureRecognizer: UILongPressGestureRecognizer) {
        onMovieCellLongPressed?(gestureRecognizer)
    }
    
    var onMovieCellLongPressed: ((UILongPressGestureRecognizer) -> ())?
    
    var onAddListButtonTapped: ((_ listName: String) -> String? )?
    var onKeyboardInvoked: (() -> ())?
    
    public func getVisibleMovieCells() -> [MovieCollectionViewCell] {
        let visibleCells = self.visibleCells.compactMap { cell -> MovieCollectionViewCell? in
            guard let cell = cell as? MovieCollectionViewCell else { return nil }
            let indexPath = self.indexPath(for: cell)
            if indexPath?.section == 0 { return nil }
            return cell
        }
        return visibleCells
    }
    
    public func appendLists(_ lists: [MovieList]) {
        var item: Item
        if lists.isEmpty {
            item = Item.emptyState("There are no lists")
        } else {
            item = Item.lists(lists)
        }
        currentSnapshot.appendItems([item], toSection: .lists)
        diffDataSource.apply(currentSnapshot)
    }
    
    public func refreshData(with movies: [Movie]) {
        isMoviesInCurrentListPresent = movies.isEmpty ? false : true
        deleteAllMovies()
        var items: [Item]
        if movies.isEmpty {
            items = [Item.emptyState("The list is empty")]
        } else {
            items = movies.map { Item.movie($0) }
        }
        currentSnapshot.appendItems(items, toSection: .movies)
        diffDataSource.apply(currentSnapshot)
    }
    
    public func getMovie(for indexPath: IndexPath) -> Movie? {
        let item = currentSnapshot.itemIdentifiers(inSection: .movies)[indexPath.item]
        
        if case let .movie(movie) = item {
            return movie
        } else {
            return nil
        }
    }
    
    public func getLists() -> [MovieList] {
        let item = currentSnapshot.itemIdentifiers(inSection: .lists)[0]
        if case let .lists(lists) = item { return lists }
        else { return [] }
    }
    
    public func deleteAllLists() {
        currentSnapshot.deleteItems([Item.lists(getLists())])
    }
    
    public func deleteAllMovies() {
        currentSnapshot.deleteSections([.movies])
        currentSnapshot.appendSections([.movies])
    }

    public func refreshData(with lists: [MovieList]) {
        if lists.isEmpty {
            currentSnapshot.appendItems([Item.emptyState("There are no lists")], toSection: .lists)
        } else {
            currentSnapshot.appendItems([Item.lists(lists)], toSection: .lists)
        }
        
        diffDataSource.apply(currentSnapshot)
    }
    
    public func addList(initialLists: [MovieList], currentLists: [MovieList]) {
        if initialLists.isEmpty {
            currentSnapshot.deleteSections([.lists, .movies])
            currentSnapshot.appendSections([.lists, .movies])
        } else {
            currentSnapshot.deleteItems([Item.lists(initialLists)])
        }
        currentSnapshot.appendItems([Item.lists(currentLists)], toSection: .lists)
        diffDataSource.apply(currentSnapshot, animatingDifferences: false)
    }
    
}


// MARK: - data source
extension MovieListsScreenCollectionVIew {
    
    private func createListsContainerCellRegistration() -> UICollectionView.CellRegistration<MovieListsContainerCell, [MovieList]> {
        UICollectionView.CellRegistration<MovieListsContainerCell, [MovieList]> { cell, indexPath, lists in
            cell.lists = lists.map { $0.name }
            cell.onListSelected = { self.onListSelected?($0) }
            cell.onListTappedToDelete = { self.onListTappedToDelete?($0) }
        }
    }
    
    private func createMovieCellRegistration() -> UICollectionView.CellRegistration<MovieCollectionViewCell, Movie> {
        UICollectionView.CellRegistration<MovieCollectionViewCell, Movie> { cell, indexPath, movie in
            cell.configure(with: movie.poster)
            let longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(self.handlePressGesture))
            cell.addGestureRecognizer(longPressGestureRecognizer)
        }
    }
    
    private func createEmptyStateCellRegistration() -> UICollectionView.CellRegistration<EmptyStateCollectionViewCell, String> {
        UICollectionView.CellRegistration<EmptyStateCollectionViewCell, String> { cell, indexPath, message in
            cell.configure(with: message)
        }
    }
    
    private func configureDataSource() {
        let listsContainerCellRegistration = createListsContainerCellRegistration()
        let movieCellRegistration = createMovieCellRegistration()
        let emptyStateRegistration = createEmptyStateCellRegistration()
        
        diffDataSource = UICollectionViewDiffableDataSource(collectionView: self) { collectionView, indexPath, itemIdentifier in
            switch itemIdentifier {
            case .lists(let model):
                return collectionView.dequeueConfiguredReusableCell(using: listsContainerCellRegistration, for: indexPath, item: model)
            case .movie(let model):
                return collectionView.dequeueConfiguredReusableCell(using: movieCellRegistration, for: indexPath, item: model)
            case .emptyState(let model):
                return collectionView.dequeueConfiguredReusableCell(using: emptyStateRegistration, for: indexPath, item: model)
            }
        }
        
        let movieListsSupplementaryRegistration = UICollectionView.SupplementaryRegistration<MovieListsSectionTitle>(elementKind: Constants.titleElementKind) { _, _, _ in}
        
        let moviesSupplementaryRegistration = UICollectionView.SupplementaryRegistration<MoviesSectionTitle>(elementKind: Constants.titleElementKind) { _, _, _ in}
        
        diffDataSource.supplementaryViewProvider = { view, kind, index in
            if index.section == 0 {
                let movieListsSectionTitle = self.dequeueConfiguredReusableSupplementary(using: movieListsSupplementaryRegistration, for: index)
                movieListsSectionTitle.delegate = self
                return movieListsSectionTitle
            } else {
                let moviesSectionTitle = self.dequeueConfiguredReusableSupplementary(using: moviesSupplementaryRegistration, for: index)
                return moviesSectionTitle
            }
        }
        
        let sections: [Section] = [.lists, .movies]
        currentSnapshot.appendSections(sections)
        diffDataSource.apply(currentSnapshot, animatingDifferences: false)
    }
    
}

// MARK: - layout
extension MovieListsScreenCollectionVIew {
    
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
    
    private enum Constants {
        static let sectionContentInset: CGFloat = 15
        static let posterAspectRatio: CGFloat = 3 / 2
        static let interGroupSpacing: CGFloat = 15
        static let titleElementKind = "title-element-kind"
    }
    
}


extension MovieListsScreenCollectionVIew: MovieListsSectionTitleDelegate {
    func didTapAddListButton(_ listName: String) -> String? {
        onAddListButtonTapped?(listName)
    }
    
    func keyboardIsInvoked() {
        onKeyboardInvoked?()
    }
    
    
}
