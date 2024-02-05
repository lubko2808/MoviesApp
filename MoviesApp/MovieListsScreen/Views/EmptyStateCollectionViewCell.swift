//
//  DefaultCollectionViewCell.swift
//  MoviesApp
//
//  Created by Любомир  Чорняк on 17.12.2023.
//


import UIKit

class EmptyStateCollectionViewCell: UICollectionViewCell {
    
    private let messageLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .largeTitle)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .secondaryLabel
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(messageLabel)
        messageLabel.snp.makeConstraints { make in
            make.centerX.centerY.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func configure(with message: String) {
        messageLabel.text = message
    }
    
}
