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
