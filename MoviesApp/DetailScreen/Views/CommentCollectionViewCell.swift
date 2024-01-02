//
//  CommentsCollectionViewCell.swift
//  MoviesApp
//
//  Created by Любомир  Чорняк on 27.08.2023.
//

import UIKit

struct CommentCollectionViewCellConfiguration {
    
    let avatarImageUrl: String?
    let name: String
    let comment: String
    private let date: String
    private let ratings: Double
    
    init(avatarImageUrl: String?, name: String, comment: String, date: String, ratings: Double) {
        self.avatarImageUrl = avatarImageUrl
        self.name = name
        self.comment = comment
        self.date = date
        self.ratings = ratings
    }
    
    public func getDate() -> String? {
        let date = String(date.prefix(10))
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        if let date = dateFormatter.date(from: date) {
            let outputDateFormatter = DateFormatter()
            outputDateFormatter.dateFormat = "d MMM yyyy"
            outputDateFormatter.locale = Locale(identifier: "en_US")
            let dayFormatter = NumberFormatter()
            dayFormatter.numberStyle = .ordinal
            
            let day = Calendar.current.component(.day, from: date)

            let month = outputDateFormatter.shortStandaloneMonthSymbols[Calendar.current.component(.month, from: date) - 1]
            let year = Calendar.current.component(.year, from: date)
            
            if let dayOrdinal = dayFormatter.string(from: NSNumber(value: day)) {
                let formattedDate = "\(dayOrdinal) \(month) \(year)"
                return formattedDate
            }
        }
        
        return nil
    }
    
    public func getRatings() -> String {
        "\(Int(ratings))/10"
    }
    
}

class CommentCollectionViewCell: UICollectionViewCell {

    var buttonClicked: (() -> (Void))!
    
    public var isCellExpanded = false

    private let avatarImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 100 / 2
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    public let commentLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    public let moreButton: UIButton = {
        let button = UIButton()
        button.setTitleColor(.black, for: .normal)
        button.setTitle("See More", for: .normal)
    
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let ratings: UILabel = {
        let label = UILabel()
        label.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let activityIndicatorView = UIActivityIndicatorView(style: .large)
    
    private var task: Task<Void, Error>?
    private var networkManager = NetworkManager()
    
    private func getImage(for imageUrl: String) {
        task?.cancel()
        
        avatarImageView.image = nil
        activityIndicatorView.startAnimating()
        
        task = Task {
            let image = await UIImage.downloadImage(with: imageUrl) ?? GlobalConstants.defaultImage
            await MainActor.run {
                self.activityIndicatorView.stopAnimating()
                self.avatarImageView.image = image
            }
        }
    }
    
    public func configure(with config: CommentCollectionViewCellConfiguration) {
        nameLabel.text = config.name
        commentLabel.text = config.comment
        dateLabel.text = config.getDate()
        ratings.text = config.getRatings()
        
        hideMoreButtonIfNeeded()
        
        guard let avatarImageUrl = config.avatarImageUrl else {
            activityIndicatorView.stopAnimating()
            avatarImageView.image = GlobalConstants.defaultImage
            return
        }
        getImage(for: avatarImageUrl)
        
    }
    
    private func hideMoreButtonIfNeeded() {

        if let title = moreButton.titleLabel?.text, title == "See More" {
            layoutIfNeeded()
            let font = commentLabel.font
            let text = commentLabel.text ?? ""
            
            let maxLabelWidth = commentLabel.frame.size.width
            let maxSize = CGSize(width: maxLabelWidth, height: CGFloat.greatestFiniteMagnitude)
            let expectedSize = (text as NSString).boundingRect(
                with: maxSize,
                options: .usesLineFragmentOrigin,
                attributes: [NSAttributedString.Key.font: font],
                context: nil
            ).size
            
            if expectedSize.height <= commentLabel.frame.size.height {
                moreButton.isHidden = true
            } else {
                moreButton.isHidden = false

            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.layer.cornerRadius = 20
        contentView.layer.masksToBounds = false
        contentView.backgroundColor = UIColor.white.withAlphaComponent(0.9)
        contentView.layer.shadowColor = UIColor.black.cgColor
        contentView.layer.shadowRadius = 5
        contentView.layer.shadowOpacity = 0.8

        contentView.addSubview(avatarImageView)
        avatarImageView.addSubview(activityIndicatorView)
        contentView.addSubview(nameLabel)
        contentView.addSubview(commentLabel)
        contentView.addSubview(dateLabel)
        contentView.addSubview(ratings)
        contentView.addSubview(moreButton)
        

        moreButton.addTarget(self, action: #selector(moreButtonTapped), for: .touchUpInside)
        
        setupConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc func moreButtonTapped(_ sender: Any) {
        buttonClicked()
    }

    private func setupConstraints() {
        
        avatarImageView.snp.makeConstraints { make in
            make.top.leading.equalToSuperview().offset(10)
            make.size.equalTo(100)
        }
        
        activityIndicatorView.snp.makeConstraints { make in
            make.leading.top.trailing.bottom.equalToSuperview()
        }
        
        ratings.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(19)
            make.trailing.equalToSuperview().inset(12)
        }
        
        nameLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(19)
            make.leading.equalTo(avatarImageView.snp.trailing).offset(10)
            make.trailing.equalTo(ratings.snp.leading).offset(-10)
        }
        
        dateLabel.snp.makeConstraints { make in
            make.leading.equalTo(avatarImageView.snp.trailing).offset(10)
            make.top.equalTo(nameLabel.snp.bottom).offset(10)
            make.trailing.equalTo(ratings.snp.leading).offset(-10)
        }
        
        commentLabel.snp.makeConstraints { make in
            make.top.equalTo(avatarImageView.snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview().inset(5)
            make.bottom.equalTo(moreButton.snp.top).offset(-10)
        }
        
        moreButton.snp.makeConstraints { make in
            make.trailing.bottom.equalToSuperview().inset(5)
        }
        
    }
    
}




