//
//  SearchViewController.swift
//  MoviesApp
//
//  Created by Любомир  Чорняк on 22.08.2023.
//

import UIKit
import SnapKit

enum Section2 {
    case main
}

class SearchViewController: UIViewController {
    
    private let collectionView: UICollectionView = {
        let collectionViewLayout = UICollectionViewLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: collectionViewLayout)
        collectionView.backgroundColor = .none
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    
    var dataSource: UICollectionViewDiffableDataSource<Section2, String>! = nil
    var currentSnapshot: NSDiffableDataSourceSnapshot<Section2, String>! = nil

    override func viewDidLoad() {
        super.viewDidLoad()

        setupViews()
        setConstraints()
        configureDataSource()
        
        currentSnapshot.appendItems(["asdsdsdsdsdsasdsdsdsdsdsasdsdsdsdsdsasdsdsdsdsdsasdsdsdsdsdsasdsdsdsdsdsasdsdsdsdsdsasdsdsdsdsdsasdsdsdsdsdsasdsdsdsdsdsasdsdsdsdsdsasdsdsdsdsdsasdsdsdsdsdsasdsdsdsdsdsasdsdsdsdsdsasdsdsdsdsds", "bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb"])
        dataSource.apply(currentSnapshot)
    }
    
    
    
    private func setupViews() {
        view.backgroundColor = .systemBackground

        collectionView.collectionViewLayout = createLayout()
        view.addSubview(collectionView)
    }
    
    
    private func setConstraints() {
        collectionView.snp.makeConstraints { make in
            make.leading.trailing.top.bottom.equalToSuperview()
        }
    }
    
    private func configureDataSource() {
        
        let cellRegistration = UICollectionView.CellRegistration<CustomCollectionViewCell, String> { cell, indexPath, text in
            cell.label.text = text
        }
        dataSource = UICollectionViewDiffableDataSource(collectionView: collectionView) {
            (collectionView, indexPath, text) -> UICollectionViewCell? in
            
            return collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: text)
        }
        
        currentSnapshot = NSDiffableDataSourceSnapshot<Section2, String>()
        currentSnapshot.appendSections([.main])
        dataSource.apply(currentSnapshot, animatingDifferences: true)

    }
    
    private func createLayout() -> UICollectionViewCompositionalLayout {
       
        let sectionProvider = { (sectionIndex: Int, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
            
            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(100))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
 
            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(100) )
            let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, repeatingSubitem: item, count: 1)
            
            let section = NSCollectionLayoutSection(group: group)

            return section
        }
        
        let config = UICollectionViewCompositionalLayoutConfiguration()
        config.interSectionSpacing = 20
        let layout = UICollectionViewCompositionalLayout(sectionProvider: sectionProvider, configuration: config)
        return layout
        
    }
}


class CustomCollectionViewCell: UICollectionViewCell {
    
    let label = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(label)
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        label.snp.makeConstraints { make in
            make.top.bottom.leading.trailing.equalToSuperview()
        }
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
