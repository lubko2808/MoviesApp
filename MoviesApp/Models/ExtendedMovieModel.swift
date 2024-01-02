//
//  ExtendedMovieModel.swift
//  MoviesApp
//
//  Created by Любомир  Чорняк on 26.08.2023.
//

import Foundation

struct ExtendedMovieModel: Codable, Hashable {
    let genres: [GenreModel]
    let id: Int
    let overview: String
    let posterPath: String
    let runtime: Int
    let title: String
    let tagline: String
    let voteAverage: Double
    
    enum CodingKeys: String, CodingKey {
        case genres
        case id
        case overview
        case posterPath = "poster_path"
        case runtime
        case title
        case tagline
        case voteAverage = "vote_average"
    }
}

struct GenreModel: Codable, Hashable {
    let id: Int
    let name: String
}
