//
//  MovieListsScreenModels.swift
//  MoviesApp
//
//  Created by Lubomyr Chorniak on 01.02.2024.
//

import Foundation

extension MovieListsScreenCollectionVIew {
    
    enum Section: Int, CaseIterable {
        case lists
        case movies
    }
    
    enum Item: Hashable {
        case lists([MovieList])
        case movie(Movie)
        case emptyState(String)
    }
    
}
