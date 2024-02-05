//
//  DetailScreenModels.swift
//  MoviesApp
//
//  Created by Lubomyr Chorniak on 14.01.2024.
//

import UIKit

struct DetailMovieModel: Hashable {
    let posterImage: UIImage
    let title: String
    let tagline: String
    let voteAverage: Double
    let genres: [GenreModel]
    let runtime: Int
    
    init(posterImage: UIImage, extendedMovieModel: ExtendedMovieModel) {
        self.posterImage = posterImage
        self.title = extendedMovieModel.title
        self.tagline = extendedMovieModel.tagline
        self.voteAverage = extendedMovieModel.voteAverage
        self.genres = extendedMovieModel.genres
        self.runtime = extendedMovieModel.runtime
    }
    
}

extension DetailScreenCollectionView {
    
    enum Section: Int, CaseIterable {
        case main
        case overview
        case cast
        case trailers
        case reviews
        
        var description: String {
            switch self {
            case .overview: return "Overview"
            case .cast: return "Cast"
            case .trailers: return "Trailers"
            case .reviews: return "Reviews"
            default: return ""
            }
        }
        
        static func intToSection(section: Int) -> Self? {
            switch section {
            case 0: return .main
            case 1: return .overview
            case 2: return .cast
            case 3: return .trailers
            case 4: return .reviews
            default: return nil
            }
        }
    }
    
    enum Item: Hashable {
        case main(DetailMovieModel)
        case overview(String)
        case castMember(Actor)
        case trailer(Trailer)
        case review(Review)
    }
    
}
