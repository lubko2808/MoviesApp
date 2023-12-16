//
//  MovieListsContainerCell.swift
//  MoviesApp
//
//  Created by Любомир  Чорняк on 16.12.2023.
//

import UIKit
import Combine
import RxSwift

class MovieListsContainerCell: UICollectionViewCell {
    
    var lists = [String]() {
        didSet {
            guard !lists.isEmpty else {
                MovieListsContainerCell.rowsCount = 0
                return
            }
            
            MovieListsContainerCell.rowsCount = 1
            let totalWidth = self.bounds.width
            
            var rowWidth = CGFloat(10)
            var i = 0
            while(i < lists.count) {
                let tagWidth = getTagCollectionViewCellWidth(text: lists[i])
                if rowWidth + tagWidth - 10 > totalWidth {
                    MovieListsContainerCell.rowsCount += 1
                    rowWidth = 10
                } else {
                    rowWidth += tagWidth + 10
                    i += 1
                }
            }

            
            DispatchQueue.main.async {
                self.tagCollectionView.reloadData()
            }
        }
    }
    
    private let disposeBag = DisposeBag()
    
    var listSelected: Observable<String> { listSelectedSubject.asObservable() }
    private let listSelectedSubject = PublishSubject<String>()

    var listTappedToDelete: Observable<Int> { listTappedToDeleteSubject.asObservable() }
    private let listTappedToDeleteSubject = PublishSubject<Int>()
    
    private let tagCollectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewLayout())
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()

    static var rowsCount: Int = 0
    
    private var subscription = Set<AnyCancellable>()
    private var timer: Timer?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setConstraints()
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func deleteTapped(_ sender: CustomButton) {
        let indexPath = IndexPath(row: sender.item, section: 0)
        
        if let selectedTag = MovieListsContainerCell.selectedTag {
            if selectedTag == indexPath {
                MovieListsContainerCell.selectedTag = nil
            } else if indexPath.item < selectedTag.item {
                MovieListsContainerCell.selectedTag?.item -= 1
            }
        }

        listTappedToDeleteSubject.onNext(indexPath.item)
        lists.remove(at: indexPath.item)
        tagCollectionView.reloadData()
    }
    
    private func setupViews() {
        let layout = TagFlowLayout(numberOfColumns: lists.count)

        
        layout.estimatedItemSize = CGSize(width: 140, height: 40)
        layout.minimumLineSpacing = 10
        tagCollectionView.collectionViewLayout = layout
        tagCollectionView.register(TagCollectionViewCell.self, forCellWithReuseIdentifier: "TagCollectionViewCell")
        tagCollectionView.dataSource = self
        tagCollectionView.delegate = self
        
        contentView.addSubview(tagCollectionView)
    }

    private func setConstraints() {
        tagCollectionView.snp.makeConstraints { make in
            make.top.leading.trailing.bottom.equalToSuperview()
        }
    }
    
    private static var selectedTag: IndexPath?
    
    
    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        super.preferredLayoutAttributesFitting(layoutAttributes)
        var newFrame = layoutAttributes.frame
        let height = CGFloat(MovieListsContainerCell.rowsCount) * (getTagCollectionViewCellHeight() + 10)
        newFrame.size.height = height
        layoutAttributes.frame = newFrame
        return layoutAttributes
        
    }
    

    
}

// MARK: - UICollectionViewDataSource
extension MovieListsContainerCell: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        lists.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TagCollectionViewCell", for: indexPath) as? TagCollectionViewCell {
            cell.tagLabel.text = lists[indexPath.item]
            cell.deleteButton.item = indexPath.item
            if MovieListsContainerCell.selectedTag == indexPath {
                cell.contentView.backgroundColor = .blue
            } else {
                cell.contentView.backgroundColor = UIColor.gray.withAlphaComponent(0.6)
            }
            cell.deleteButton.addTarget(self, action: #selector(deleteTapped), for: .touchUpInside)
            return cell
        }
        
        return UICollectionViewCell()
    }
    

    
}

// MARK: - UICollectionViewDelegate
extension MovieListsContainerCell: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        print("shouldSelectItemAt")
        guard let currentSelectedCell = collectionView.cellForItem(at: indexPath) as? TagCollectionViewCell else { return false  }
        
        if let previouslySelectedTag = MovieListsContainerCell.selectedTag {
            guard let previouslySelectedCell = collectionView.cellForItem(at: previouslySelectedTag) as? TagCollectionViewCell else { return false }
            previouslySelectedCell.contentView.backgroundColor = UIColor.gray.withAlphaComponent(0.6)
        }
        
        currentSelectedCell.contentView.backgroundColor = .blue
        MovieListsContainerCell.selectedTag = indexPath

        listSelectedSubject.onNext(lists[indexPath.item])
        return true
    }

    
    private func getTagCollectionViewCellWidth(text: String?) -> CGFloat {
        let label = UILabel()
        label.text = text
        let tagLabelWidth = label.intrinsicContentSize.width
        
        let button = CustomButton()
        let image = UIImage(systemName: "trash.circle.fill")
        button.setImage(image, for: .normal)
        let deleteButtonWidth = button.intrinsicContentSize.width
        
        let width = 5 + tagLabelWidth + 10 + deleteButtonWidth
        return width
    }
    
    private func getTagCollectionViewCellHeight() -> CGFloat {
        let label = UILabel()
        label.text = "placeholder"
        let tagLabelHeight = label.intrinsicContentSize.height
        
        let totalHeight = tagLabelHeight + 10
        return totalHeight
    }
    
    
}
