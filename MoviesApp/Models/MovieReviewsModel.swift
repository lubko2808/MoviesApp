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
}

struct Review: Codable, Hashable {
    let author: String
    let authorDetails: AuthorDetails
    let content: String
    let createdAt: String
    
    enum CodingKeys: String, CodingKey {
        case author
        case authorDetails = "author_details"
        case content
        case createdAt = "created_at"
    }
}

struct AuthorDetails: Codable, Hashable {
    let avatarPath: String?
    let rating: Double?
    
    enum CodingKeys: String, CodingKey {
        case avatarPath = "avatar_path"
        case rating
    }
}
