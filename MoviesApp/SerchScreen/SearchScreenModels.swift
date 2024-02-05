//
//  SearchScreenModels.swift
//  MoviesApp
//
//  Created by Lubomyr Chorniak on 25.01.2024.
//

import Foundation

extension SearchScreenCollectionView {
    
    enum Section: Int, Hashable {
        case genres
        case movies
    }
    
//    struct Item: Hashable {
//        
//        let genre: Genre?
//        let movie: MovieInfo?
//        
//        init(genre: Genre? = nil, movie: MovieInfo? = nil) {
//            self.genre = genre
//            self.movie = movie
//        }
//    }
    
    enum Item: Hashable {
        case genre(Genre)
        case movie(MovieInfo)
        case emptyState
    }
    
}
