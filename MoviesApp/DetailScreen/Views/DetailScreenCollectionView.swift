//
//  DetailScreenCollectionView.swift
//  MoviesApp
//
//  Created by Lubomyr Chorniak on 14.01.2024.
//

import UIKit

class DetailScreenCollectionView: UICollectionView {
    
    private enum Constants {
        static let titleElementKind = "title-element-kind"
    }
    
    private var diffDataSource: UICollectionViewDiffableDataSource<Section, Item>
    private var currentSnapshot = NSDiffableDataSourceSnapshot<Section, Item>()
    private var expandedcell: IndexSet = []
    
    init() {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewLayout())
        diffDataSource = UICollectionViewDiffableDataSource(collectionView: collectionView) { _, _, _ in UICollectionViewCell()}
        
        super.init(frame: .zero, collectionViewLayout: UICollectionViewLayout())
        collectionViewLayout = createLayout()
        backgroundColor = .none
        showsVerticalScrollIndicator = false
        showsHorizontalScrollIndicator = false
        translatesAutoresizingMaskIntoConstraints = false
        isHidden = true

        let mainCellRegistration = createMainCellRegistration()
        let overviewCellRegistration = createOverviewCellRegistration()
        let castCellRegistration = createCastCellRegistration()
        let trailerCellRegistration = createTrailerCellRegistration()
        let reviewCellRegistration = createReviewCellRegistration()
        diffDataSource = UICollectionViewDiffableDataSource(collectionView: self) { collectionView, indexPath, itemIdentifier in
            switch itemIdentifier {
            case .main(let model):
                return collectionView.dequeueConfiguredReusableCell(using: mainCellRegistration, for: indexPath, item: model)
            case .overview(let model):
                return collectionView.dequeueConfiguredReusableCell(using: overviewCellRegistration, for: indexPath, item: model)
            case .castMember(let model):
                return collectionView.dequeueConfiguredReusableCell(using: castCellRegistration, for: indexPath, item: model)
            case .trailer(let model):
                return collectionView.dequeueConfiguredReusableCell(using: trailerCellRegistration, for: indexPath, item: model)
            case .review(let model):
                return collectionView.dequeueConfiguredReusableCell(using: reviewCellRegistration, for: indexPath, item: model)
            }
        }
        
        let supplementaryRegistration = UICollectionView.SupplementaryRegistration<TitleSupplementaryView>(elementKind: Constants.titleElementKind) { supplementaryView, elementKind, indexPath in
            supplementaryView.label.text = Section.intToSection(section: indexPath.section)?.description
        }
        diffDataSource.supplementaryViewProvider = { view, kind, index in
            guard let section = Section(rawValue: index.section) else { return nil }
            if section != .main {
                return self.dequeueConfiguredReusableSupplementary(using: supplementaryRegistration, for: index)
            }
            
            return nil
        }
        
        currentSnapshot.appendSections([.main, .overview, .cast, .trailers, .reviews])
        diffDataSource.apply(currentSnapshot, animatingDifferences: true)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func appendItems(_ items: [Item], to section: Section) {
        if items.isEmpty {
            currentSnapshot.deleteSections([section])
        } else {
            currentSnapshot.appendItems(items, toSection: section)
        }
        diffDataSource.apply(currentSnapshot, animatingDifferences: true)
    }
    
    // MARK: - data source
    private func createMainCellRegistration() -> UICollectionView.CellRegistration<DetailCollectionViewCell, DetailMovieModel> {
        UICollectionView.CellRegistration<DetailCollectionViewCell, DetailMovieModel> { (cell, indexPath, item) in
            let viewModel = DetailCollectionViewCellViewModel(detailMovieModel: item)
            cell.configureCell(with: viewModel)
        }
    }
    
    private func createOverviewCellRegistration() -> UICollectionView.CellRegistration<OverviewCollectionViewCell, String> {
        UICollectionView.CellRegistration<OverviewCollectionViewCell, String> { (cell, indexPath, overview) in
            cell.configure(with: overview)
        }
    }

    private func createCastCellRegistration() -> UICollectionView.CellRegistration<CastCollectionViewCell, Actor> {
        UICollectionView.CellRegistration<CastCollectionViewCell, Actor> { (cell, indexPath, movieActor) in
            cell.configure(with: movieActor.profilePath, actorName: movieActor.name)
        }
    }

    private func createTrailerCellRegistration() -> UICollectionView.CellRegistration<TrailerCollectionViewCell, Trailer> {
        UICollectionView.CellRegistration<TrailerCollectionViewCell, Trailer> { (cell, indexPath, trailer) in
            cell.configureCell(with: trailer.key)
        }
    }

    private func createReviewCellRegistration() -> UICollectionView.CellRegistration<CommentCollectionViewCell, Review> {
        UICollectionView.CellRegistration<CommentCollectionViewCell, Review> { [weak self] (cell, indexPath, commentInfo) in
            let cellViewModel = CommentCollectionViewCellViewModel(review: commentInfo)
            cell.configure(with: cellViewModel)
            
            let isExpandedCell = self?.expandedcell.contains(indexPath.item)
            if let isExpandedCell, isExpandedCell == true {
                cell.commentLabel.numberOfLines = 0
                cell.moreButton.setTitle("See Less", for: .normal)
            } else {
                cell.commentLabel.numberOfLines = 3
                cell.moreButton.setTitle("See More", for: .normal)
            }
            
            cell.buttonClicked = {
                guard let self = self else { return }
                if self.expandedcell.contains(indexPath.item) {
                    self.expandedcell.remove(indexPath.item)
                } else {
                    self.expandedcell.insert(indexPath.item)
                }
                
                let item = Item.review(commentInfo)
                self.currentSnapshot.reconfigureItems([item])
                self.diffDataSource.apply(self.currentSnapshot, animatingDifferences: false)
                self.layoutIfNeeded()
            }
        }
    }
    
    // MARK: - layout
    private func createLayout() -> UICollectionViewCompositionalLayout {

        let sectionProvider = { (sectionIndex: Int, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in

            guard let sectionKind = Section(rawValue: sectionIndex) else { return nil }
            let section: NSCollectionLayoutSection

            switch sectionKind {
            case .main:
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(300))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(300))
                let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
                section = NSCollectionLayoutSection(group: group)
                section.contentInsets = NSDirectionalEdgeInsets(top: 30, leading: 10, bottom: 10, trailing: 10)

            case .overview:
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(100))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(100))
                let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
                section = NSCollectionLayoutSection(group: group)
                section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10)

            case .cast:
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                let groupSize = NSCollectionLayoutSize(widthDimension: .absolute(110), heightDimension: .fractionalHeight(0.2))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
                section = NSCollectionLayoutSection(group: group)
                section.interGroupSpacing = 10
                section.orthogonalScrollingBehavior = .continuousGroupLeadingBoundary
                section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10)

            case .trailers:
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.7), heightDimension: .fractionalHeight(0.3))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
                section = NSCollectionLayoutSection(group: group)
                section.interGroupSpacing = 10
                section.orthogonalScrollingBehavior = .groupPaging
                section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10)

            case .reviews:
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(200))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(200))
                let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
                section = NSCollectionLayoutSection(group: group)
                section.interGroupSpacing = 10
                section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10)
            }

            if sectionKind != .main {
                let titleSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(44))
                let titleSupplementary = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: titleSize, elementKind: Constants.titleElementKind, alignment: .top)
                section.boundarySupplementaryItems = [titleSupplementary]
            }

            return section
        }

        let config = UICollectionViewCompositionalLayoutConfiguration()
        config.interSectionSpacing = 20
        let layout = UICollectionViewCompositionalLayout(sectionProvider: sectionProvider, configuration: config)
        return layout

    }
}
