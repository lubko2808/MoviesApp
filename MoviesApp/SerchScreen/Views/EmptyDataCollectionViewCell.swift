//
//  EmptyDataCollectionViewCell.swift
//  MoviesApp
//
//  Created by Любомир  Чорняк on 22.12.2023.
//
import UIKit

class EmptyDataCollectionViewCell: UICollectionViewCell {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        let imageView = UIImageView()
        imageView.image = UIImage(named: "emptydata")
        contentView.addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.leading.trailing.top.bottom.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
