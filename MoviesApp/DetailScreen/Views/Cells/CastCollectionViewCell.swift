//
//  CastCollectionViewCell.swift
//  MoviesApp
//
//  Created by Любомир  Чорняк on 27.08.2023.
//

import UIKit

class CastCollectionViewCell: UICollectionViewCell {
    
    private enum Constants {
        static let actorImageSize: CGFloat = 100
    }
    
    private let actorImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = Constants.actorImageSize / 2
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let actorNameLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 2
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let activityIndicatorView = UIActivityIndicatorView(style: .large)
    
    private var task: Task<Void, Error>?
    private var timer: Timer?
    
    func configure(with imageUrl: String?, actorName: String) {
        actorNameLabel.text = actorName
        guard let imageUrl = imageUrl else {
            activityIndicatorView.stopAnimating()
            actorImageView.image = GlobalConstants.defaultImage
            return
        }
        getImage(for: imageUrl)
    }
    
    private func getImage(for imageUrl: String) {
        task?.cancel()
        
        actorImageView.image = nil
        activityIndicatorView.startAnimating()
        
        task = Task {
            let image = await UIImage.downloadImage(with: imageUrl) ?? GlobalConstants.defaultImage
            await MainActor.run {
                self.activityIndicatorView.stopAnimating()
                self.actorImageView.image = image
            }
        }
    }

    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = .clear
        contentView.addSubview(actorImageView)
        contentView.addSubview(actorNameLabel)
        actorImageView.addSubview(activityIndicatorView)
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupConstraints() {
        actorImageView.snp.makeConstraints { make in
            make.leading.top.trailing.equalToSuperview().inset(5)
            make.size.equalTo(Constants.actorImageSize)
        }
        
        actorNameLabel.snp.makeConstraints { make in            
            make.leading.trailing.equalToSuperview().inset(7)
            make.top.equalTo(actorImageView.snp.bottom).offset(5)
            make.bottom.greaterThanOrEqualToSuperview().offset(-5)
        }
        
        
        activityIndicatorView.snp.makeConstraints { make in
            make.leading.top.trailing.bottom.equalToSuperview()
        }
        
    }
}


