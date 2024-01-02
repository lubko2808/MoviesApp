//
//  SearchMovieModel.swift
//  MoviesApp
//
//  Created by Любомир  Чорняк on 25.12.2023.
//

import Foundation

struct SearchMovieModel: Decodable {
    let results: [SearchMovieInfo]
    let totalPages: Int
    
    enum CodingKeys: String, CodingKey {
        case totalPages = "total_pages"
        case results
    }
}

struct SearchMovieInfo: Decodable, Hashable {
    let genreIds: [Int]
    let title: String
    let posterPath: String?
    let id: Int
    let releaseDate: String
    let voteAverage: Double
    let voteCount: Int
    let originalLanguage: String
    
    enum CodingKeys: String, CodingKey {
        case genreIds = "genre_ids"
        case title
        case posterPath = "poster_path"
        case id
        case releaseDate = "release_date"
        case voteAverage = "vote_average"
        case voteCount = "vote_count"
        case originalLanguage = "original_language"
    }
}
