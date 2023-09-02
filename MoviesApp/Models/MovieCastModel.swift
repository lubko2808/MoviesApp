//
//  MovieCastModel.swift
//  MoviesApp
//
//  Created by Любомир  Чорняк on 27.08.2023.
//

import Foundation

struct MovieCastModel: Codable, Hashable {
    let id: Int
    let cast: [Actor]
}

struct Actor: Codable, Hashable {
    let name: String
    let profile_path: String?
}

