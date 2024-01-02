//
//  MainScreenCollectionView.swift
//  MoviesApp
//
//  Created by Lubomyr Chorniak on 02.01.2024.
//

import UIKit
class MainScreenCollectionView: UICollectionView {
    
    private enum Constants {
        static let titleElementKind = "title-element-kind"
        static let interGroupSpacing: CGFloat = 15
        static let sectionContentInset: CGFloat = 15
    }
    
    private lazy var diffDataSource = MainScreenDataSource(collectionView: self)
    private var currentSnapshot = NSDiffableDataSourceSnapshot<Section, Item>()
        
    var horizontalSectionDidScroll: ( (_ contentOffset: CGFloat,
                                       _ itemWidth: CGFloat,
                                       _ section: Section,
                                       _ environment: NSCollectionLayoutEnvironment) -> Void )?
    
    init() {
        super.init(frame: .zero, collectionViewLayout: UICollectionViewLayout())
        collectionViewLayout = createLayout()
        backgroundColor = .none
        showsVerticalScrollIndicator = false
        showsHorizontalScrollIndicator = false
        translatesAutoresizingMaskIntoConstraints = false
        
        currentSnapshot.appendSections([.nowPlayingMovies, .upcomingMovies, .topRatedMovies, .popularMovies])
        diffDataSource.apply(currentSnapshot, animatingDifferences: true)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
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
                guard let itemWidth = visibleItems.last?.frame.width else { return }
                guard let section = Section.intToSection(section: sectionIndex) else { return }
                let contentOffset = point.x
                self?.horizontalSectionDidScroll?(contentOffset, itemWidth, section, environment)
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
    
    public func appendMovies(_ movies: [Item], toSection sectionidentifier: Section) {
        currentSnapshot.appendItems(movies, toSection: sectionidentifier)
        diffDataSource.apply(currentSnapshot, animatingDifferences: true)
    }

}
