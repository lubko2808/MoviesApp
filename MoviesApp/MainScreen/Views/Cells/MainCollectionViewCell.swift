//
//  MainCollectionViewCell.swift
//  MoviesApp
//
//  Created by Любомир  Чорняк on 22.08.2023.
//

import UIKit

class MainCollectionViewCell: UICollectionViewCell {

    let posterImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 30
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.numberOfLines = 0
        label.shadowColor = .black
        label.shadowOffset = CGSize(width: 1, height: 1)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let activityIndicatorView = UIActivityIndicatorView(style: .large)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        setConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private var task: Task<Void, Error>?
    private var networkManager = NetworkManager()
    
    public func configure(with imageUrl: String?, title: String) {
        titleLabel.text = title
        guard let imageUrl = imageUrl else {
            activityIndicatorView.stopAnimating()
            posterImageView.image = GlobalConstants.defaultImage
            return
        }
        getImage(for: imageUrl)
    }
    
    public func configure(with image: UIImage?, title: String) {
        posterImageView.image = image ?? GlobalConstants.defaultImage
        titleLabel.text = title
    }
    
    private func getImage(for imageUrl: String) {
        task?.cancel()
        
        posterImageView.image = nil
        activityIndicatorView.startAnimating()
        
        task = Task {
            let image = await UIImage.downloadImage(with: imageUrl)
            await MainActor.run {
                self.activityIndicatorView.stopAnimating()
                self.posterImageView.image = image
            }
        }
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
        contentView.addSubview(activityIndicatorView)
    }
    
    private func setConstraints() {
        posterImageView.snp.makeConstraints { make in
            make.leading.trailing.top.bottom.equalToSuperview().inset(5)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(13)
            make.bottom.equalToSuperview().offset(-18)
            make.trailing.equalToSuperview().offset(-20)
        }
        
        activityIndicatorView.snp.makeConstraints { make in
            make.leading.trailing.top.bottom.equalToSuperview()
        }
        
    }
    
}
