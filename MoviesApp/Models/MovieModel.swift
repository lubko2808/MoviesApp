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
    let posterPath: String?
    let id: Int
    
    enum CodingKeys: String, CodingKey {
        case title
        case posterPath = "poster_path"
        case id
    }
}


