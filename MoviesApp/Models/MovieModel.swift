//
//  MovieModel.swift
//  MoviesApp
//
//  Created by Любомир  Чорняк on 22.08.2023.
//

import Foundation

struct MovieModel: Decodable {
    let results: [MovieInfo]
}

struct MovieInfo: Decodable, Hashable {
    let title: String
    let poster_path: String?
    let id: Int
}

struct MovieModelForSearch: Decodable {
    let results: [MovieInfoForSearch]
    let total_pages: Int 
}

struct MovieInfoForSearch: Decodable, Hashable {
    let genre_ids: [Int]
    let title: String
    let poster_path: String?
    let id: Int
    let release_date: String
    let vote_average: Double
    let vote_count: Int
    let original_language: String
}

