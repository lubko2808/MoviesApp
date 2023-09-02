//
//  MovieTrailersModel.swift
//  MoviesApp
//
//  Created by Любомир  Чорняк on 27.08.2023.
//

import Foundation

// MARK: - Welcome
struct MovieTrailersModel: Codable, Hashable {
    let results: [Trailer]
}

struct Trailer: Codable, Hashable {
    let key: String
    let site: Site
}

enum Site: String, Codable, Hashable {
    case youTube = "YouTube"
}

