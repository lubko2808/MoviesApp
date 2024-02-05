//
//  MovieCollectionViewCell.swift
//  MoviesApp
//
//  Created by Любомир  Чорняк on 17.12.2023.
//

import UIKit

class MovieCollectionViewCell: UICollectionViewCell {
    
    let posterImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    let selectedToDeleteImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.isHidden = true
        return imageView
    }()
        
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        setConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
     
    public func configure(with imageData: Data?) {
        guard let image = UIImage(data: imageData ?? Data()) else {
            posterImageView.image = GlobalConstants.defaultImage
            return
        }
        posterImageView.image = image
    }
    
    private func setupView() {
        contentView.layer.masksToBounds = false
        contentView.layer.shadowColor = UIColor.black.cgColor
        contentView.layer.shadowRadius = 4
        contentView.layer.shadowOpacity = 0.8
        
        contentView.addSubview(posterImageView)
        contentView.addSubview(selectedToDeleteImageView)
    }
    
    private func setConstraints() {
        posterImageView.snp.makeConstraints { make in
            make.leading.trailing.top.bottom.equalToSuperview()
        }
        
        selectedToDeleteImageView.snp.makeConstraints { make in
            make.trailing.bottom.equalToSuperview().inset(15)
            make.height.width.equalTo(30)
        }

    }
}
