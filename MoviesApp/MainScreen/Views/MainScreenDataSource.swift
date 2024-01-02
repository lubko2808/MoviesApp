//
//  MainScreenDataSource.swift
//  MoviesApp
//
//  Created by Lubomyr Chorniak on 02.01.2024.
//

import UIKit

class MainScreenDataSource: UICollectionViewDiffableDataSource<MainScreenCollectionView.Section, MainScreenCollectionView.Item> {
    
    private enum Constants {
        static let titleElementKind = "title-element-kind"
    }

    init(collectionView: UICollectionView) {
        let cellRegistration = UICollectionView.CellRegistration<MainCollectionViewCell, MainScreenCollectionView.Item> { cell, indexPath, movie in
            cell.configure(with: movie.posterPath, title: movie.title)
        }
        
        super.init(collectionView: collectionView) { collectionView, indexPath, movie in
            return collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: movie)
        }
        
        let supplementaryRegistration = UICollectionView.SupplementaryRegistration<TitleSupplementaryView>(elementKind: Constants.titleElementKind) { supplementaryView, elementKind, indexPath in
            
            supplementaryView.label.text = MainScreenCollectionView.Section.intToSection(section: indexPath.item)?.rawValue
    
        }
        
        supplementaryViewProvider = { view, kind, index in
            collectionView.dequeueConfiguredReusableSupplementary(using: supplementaryRegistration, for: index)
        }
        
    }
    
}
