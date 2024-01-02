//
//  OverviewCollectionViewCell.swift
//  MoviesApp
//
//  Created by Любомир  Чорняк on 27.08.2023.
//

import UIKit

class OverviewCollectionViewCell: UICollectionViewCell {
    
    private let overviewLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16)
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.layer.cornerRadius = 20
        contentView.layer.masksToBounds = false
        contentView.backgroundColor = UIColor.white.withAlphaComponent(0.9)
        contentView.layer.shadowColor = UIColor.black.cgColor
        contentView.layer.shadowRadius = 5
        contentView.layer.shadowOpacity = 0.8
        contentView.addSubview(overviewLabel)
        overviewLabel.snp.makeConstraints { make in
            make.trailing.leading.top.bottom.equalTo(contentView.layoutMargins)
        }
        
    }
    
    public func configure(with text: String) {
        overviewLabel.text = text
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
