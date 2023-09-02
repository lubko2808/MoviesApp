//
//  ExtendedMovieModel.swift
//  MoviesApp
//
//  Created by Любомир  Чорняк on 26.08.2023.
//

import Foundation

struct ExtendedMovieModel: Codable, Hashable {
    let genres: [Genre]
    let homepage: String
    let id: Int
    let overview: String
    let poster_path: String
    let runtime: Int
    let title: String
    let tagline: String
    let vote_average: Double
}

struct Genre: Codable, Hashable {
    let id: Int
    let name: String
}
