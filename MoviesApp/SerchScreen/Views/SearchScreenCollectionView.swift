//
//  SearchScreenCollectionView.swift
//  MoviesApp
//
//  Created by Lubomyr Chorniak on 25.01.2024.
//

import UIKit

class SearchScreenCollectionView: UICollectionView {
    
    enum Constants {
        static let sectionFooterElementKind = "section-footer-element-kind"
    }
    
    private var diffDataSource: UICollectionViewDiffableDataSource<Section, Item>
    private var currentSnapshot = NSDiffableDataSourceSnapshot<Section, Item>()
    public var footer: Bool = false
    
    private var isCellAppearedFirstTime = true
    
    public var selectedGenre: IndexPath?
    public var isMovieContentAvailable = false 

    
    init() {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewLayout())
        diffDataSource = UICollectionViewDiffableDataSource(collectionView: collectionView) { _, _, _ in UICollectionViewCell()}
        super.init(frame: .zero, collectionViewLayout: UICollectionViewLayout())
        backgroundColor = .none
        showsVerticalScrollIndicator = false
        showsHorizontalScrollIndicator = false
        translatesAutoresizingMaskIntoConstraints = false
        
        collectionViewLayout = createLayout()
        configureDataSource()
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    public func makeEmptyState() {
        if isMovieContentAvailable {
            isMovieContentAvailable = false
            currentSnapshot.appendItems([Item.emptyState], toSection: .movies)
            diffDataSource.apply(currentSnapshot)
        }    
    }
    
    public func deleteAllItemsInMoviesSection() {
        isMovieContentAvailable = true 
        currentSnapshot.deleteItems(currentSnapshot.itemIdentifiers(inSection: .movies))
        diffDataSource.apply(currentSnapshot)
    }

    public func getMovie(for indexPath: IndexPath) -> MovieInfo? {
        let item = currentSnapshot.itemIdentifiers(inSection: .movies)[indexPath.item]
        
        if case let .movie(movie) = item {
            return movie
        } else {
            return nil
        }
    }
    
    public func appendMovies(movies: [MovieInfo]) {
        isMovieContentAvailable = true
        
        var movies = movies
        // delete possible duplicates
        movies.forEach { movie in
            let count = movies.filter {$0 == movie}.count
            if count > 1 {
                movies.removeAll {$0 == movie}
                movies.append(movie)
            }
            
            let item = Item.movie(movie)
            if self.currentSnapshot.itemIdentifiers.contains(where: {$0 == item}) {
                movies.removeAll(where: {$0 == movie})
            }
            
        }
        
        let items = movies.map {Item.movie($0)}
        self.currentSnapshot.appendItems(items, toSection: .movies)
        self.diffDataSource.apply(self.currentSnapshot)
        
    }
  
}

// MARK: - data source
extension SearchScreenCollectionView {
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
        
        diffDataSource = UICollectionViewDiffableDataSource(collectionView: self) {
            (collectionView: UICollectionView, indexPath: IndexPath, item: Item) -> UICollectionViewCell? in
            switch item {
            case .genre(let model):
                return collectionView.dequeueConfiguredReusableCell(using: genreCellRegistration, for: indexPath, item: model)
            case .movie(let model):
                return collectionView.dequeueConfiguredReusableCell(using: movieCellRegistration, for: indexPath, item: model)
            case .emptyState:
                return collectionView.dequeueConfiguredReusableCell(using: emptyDataCellRegistration, for: indexPath, item: ())
            }
        }
        
        let sections: [Section] = [.genres, .movies]
        currentSnapshot = NSDiffableDataSourceSnapshot<Section, Item>()
        currentSnapshot.appendSections(sections)
        var genres: [Item] = []
        Genre.allCases.forEach { genre in
            genres.append(Item.genre(genre))
        }
        currentSnapshot.appendItems(genres, toSection: .genres)
        
        currentSnapshot.appendItems([Item.emptyState], toSection: .movies)
        diffDataSource.apply(currentSnapshot, animatingDifferences: true)
        
        
    }
}

// MARK: - layout
extension SearchScreenCollectionView {
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
                
                if self.isMovieContentAvailable {
                    let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalWidth(1  * GlobalConstants.posterAspectRatio ))
                    let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
                    section = NSCollectionLayoutSection(group: group)
                    section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 50, bottom: 10, trailing: 50)
                } else {
                    let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(0.5))
                    let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
                    section = NSCollectionLayoutSection(group: group)
                    section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10)
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
