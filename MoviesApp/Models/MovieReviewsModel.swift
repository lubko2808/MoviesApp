//
//  MovieReviewsModel.swift
//  MoviesApp
//
//  Created by Любомир  Чорняк on 27.08.2023.
//

import Foundation

struct MovieReviewsModel: Codable, Hashable {
    let page: Int
    let results: [Review]
    let total_pages: Int
    let total_results: Int
}

struct Review: Codable, Hashable {
    let author: String
    let author_details: AuthorDetails
    let content: String
    let created_at: String
}

struct AuthorDetails: Codable, Hashable {
    let avatar_path: String?
    let rating: Double?
}
