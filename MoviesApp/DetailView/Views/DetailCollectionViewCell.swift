//
//  MainCollectionViewCell.swift
//  MoviesApp
//
//  Created by Любомир  Чорняк on 27.08.2023.
//

import UIKit

struct DetailCollectionViewCellConfiguration {
    
    private let genresDict = [
        28: "Action",
        12: "Adventure",
        16: "Animation",
        35: "Comedy",
        80: "Crime",
        99: "Documentary",
        18: "Drama",
        10751: "Family",
        14: "Fantasy",
        36: "History",
        27: "Horror",
        10402: "Music",
        9648: "Mystery",
        10749: "Romance",
        878: "Science Fiction",
        10770: "TV Movie",
        53: "Thriller",
        10752: "War",
        37: "Western",
    ]
    
    init(posterImage: UIImage, title: String, tagline: String, averageVote: Double, genres: [Int], duration: Int) {
        self.posterImage = posterImage
        self.title = title
        self.tagline = tagline
        self.averageVote = averageVote
        self.genres = genres
        self.duration = duration
    }
    
    let posterImage: UIImage
    let title: String
    let tagline: String
    private let averageVote: Double
    private let genres: [Int]
    private let duration: Int
    
    public func getStars() -> Int {
        if averageVote >= 0 && averageVote < 3 {
            return 1
        } else if averageVote >= 3 && averageVote < 5 {
            return 2
        } else if averageVote >= 5 && averageVote < 7 {
            return 3
        } else if averageVote >= 7 && averageVote < 9 {
            return 4
        } else if averageVote >= 9 &&  averageVote <= 10 {
            return 5
        } else {
            return 5
        }
    }
    
    public func getDuration() -> String {
        let hours = duration / 60
        let minutes = duration % 60
        
        var movieDuration: String
        if hours == 0 {
            movieDuration = "\(minutes) mins"
        } else if minutes == 0 {
            movieDuration = "\(hours) hr"
        } else {
            movieDuration = "\(hours)hr \(minutes) mins"
        }
        
        return movieDuration
    }
    
    public func getGenres() -> String {
        guard !genres.isEmpty else { return ""}
        var movieGenres = ""
        for genre in genres {
            movieGenres.append("\(genresDict[genre] ?? "")/")
        }
        movieGenres.removeLast()
        return movieGenres
    }
    
}

class DetailCollectionViewCell: UICollectionViewCell {
    
    let posterImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = false
        imageView.layer.shadowColor = UIColor.black.cgColor
        imageView.layer.shadowOpacity = 0.8
        imageView.layer.shadowOffset = CGSize(width: 5, height: 3)
        imageView.layer.shadowRadius = 3
        return imageView
    }()

    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 30, weight: .bold)
        label.textColor = .black
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let taglineLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .subheadline)
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let starImageViews: [UIImageView] = {
        var imageViews: [UIImageView] = []
        for _ in 0..<5 {
            let starImageView = UIImageView()
            starImageView.image = UIImage(systemName: "star")?.withTintColor(.gray, renderingMode: .alwaysOriginal)
            imageViews.append(starImageView)
        }
        return imageViews
    }()
    
    private let starsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .equalSpacing
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private let genresLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .body)
        label.numberOfLines = 0
        label.textColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let durationLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .body)
        label.textColor = .gray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setupConstraints()

    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    private func setupViews() {
        contentView.layer.cornerRadius = 20
        contentView.layer.masksToBounds = false
        contentView.backgroundColor = UIColor.white
        contentView.layer.shadowColor = UIColor.black.cgColor
        contentView.layer.shadowRadius = 5
        contentView.layer.shadowOpacity = 0.8
        
        contentView.addSubview(posterImageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(taglineLabel)
        contentView.addSubview(starsStackView)
        contentView.addSubview(genresLabel)
        contentView.addSubview(durationLabel)
        
        for star in starImageViews {
            starsStackView.addArrangedSubview(star)
        }
    }
    
    private func setupConstraints() {
        posterImageView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.leading.equalToSuperview().offset(10)
            make.width.equalTo(Constants.posterImageViewSize)
            make.height.equalTo(Constants.posterImageViewSize * Constants.posterImageAspectRatio)
            make.bottom.lessThanOrEqualToSuperview().offset(-15)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-5)
            make.leading.equalTo(posterImageView.snp.trailing).offset(10)
        }
        
        taglineLabel.snp.makeConstraints { make in
            make.leading.equalTo(posterImageView.snp.trailing).offset(10)
            make.top.equalTo(titleLabel.snp.bottom).offset(10)
            make.trailing.equalToSuperview().offset(-10)
        }
        
        starsStackView.snp.makeConstraints { make in
            make.leading.equalTo(posterImageView.snp.trailing).offset(10)
            make.top.equalTo(taglineLabel.snp.bottom).offset(15)
            make.width.equalTo(120)
        }
        
        genresLabel.snp.makeConstraints { make in
            make.leading.equalTo(posterImageView.snp.trailing).offset(10)
            make.top.equalTo(starsStackView.snp.bottom).offset(15)
            make.trailing.equalToSuperview().offset(-10)
        }
        
        durationLabel.snp.makeConstraints { make in
            make.leading.equalTo(posterImageView.snp.trailing).offset(10)
            make.top.equalTo(genresLabel.snp.bottom).offset(15)
            make.trailing.equalToSuperview().offset(-20)
            make.bottom.lessThanOrEqualToSuperview().offset(-10)
        }
    
        

    }
    
    private enum Constants {
        static let starImageColor = #colorLiteral(red: 0.9529411793, green: 0.6862745285, blue: 0.1333333403, alpha: 1)
        static let posterImageViewSize: CGFloat = 180
        static let posterImageAspectRatio: CGFloat = 3 / 2
    }
    
    public func configureCell(with config: DetailCollectionViewCellConfiguration) {
        posterImageView.image = config.posterImage
        titleLabel.text = config.title
        taglineLabel.text = config.tagline
        
        for star in 0..<config.getStars() {
            starImageViews[star].image =  UIImage(systemName: "star.fill")?.withTintColor(Constants.starImageColor, renderingMode: .alwaysOriginal)
        }

        genresLabel.text = config.getGenres()
        durationLabel.text = config.getDuration()
    }
    
}
