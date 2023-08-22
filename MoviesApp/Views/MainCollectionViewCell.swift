//
//  MainCollectionViewCell.swift
//  MoviesApp
//
//  Created by Любомир  Чорняк on 22.08.2023.
//

import UIKit

class MainCollectionViewCell: UICollectionViewCell {

    private let posterImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 30
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = UIFont.boldSystemFont(ofSize: 35)
        label.numberOfLines = 0
        label.shadowColor = .black
        label.shadowOffset = CGSize(width: 1, height: 1)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        setConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    public func configureCell(with poster: UIImage?, movieTitle: String) {
        if let poster = poster {
            posterImageView.image = poster
        } else {
            posterImageView.image = UIImage(named: "backup")
        }
        
        titleLabel.text = movieTitle
    }
    
    private func setupView() {
        contentView.layer.borderWidth = 8
        contentView.layer.borderColor = UIColor.white.cgColor
        contentView.layer.cornerRadius = 30
        contentView.layer.masksToBounds = false
        contentView.layer.shadowColor = UIColor.black.cgColor
        contentView.layer.shadowRadius = 4
        contentView.layer.shadowOpacity = 0.8
        
        contentView.addSubview(posterImageView)
        contentView.addSubview(titleLabel)
    }
    
    private func setConstraints() {
        posterImageView.snp.makeConstraints { make in
            make.leading.trailing.top.bottom.equalToSuperview()
        }
        
        titleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(27)
            make.bottom.equalToSuperview().offset(-27)
            make.trailing.equalToSuperview().offset(-35)
        }
    }
    
    
}
