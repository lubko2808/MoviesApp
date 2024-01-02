//
//  MainScreenModels.swift
//  MoviesApp
//
//  Created by Lubomyr Chorniak on 02.01.2024.
//

import Foundation

struct MovieItem: Hashable {
    let title: String
    let posterPath: String?
    let id: Int
    let section: Categories
}

enum Categories: String {
    case nowPlayingMovies = "Now Playing"
    case upcomingMovies = "Upcoming"
    case topRatedMovies = "Top Rated"
    case popularMovies = "Popular"
    
    static func intToCategories(section: Int) -> Categories? {
        switch section {
        case 0: return .nowPlayingMovies
        case 1: return .upcomingMovies
        case 2: return .topRatedMovies
        case 3: return .popularMovies
        default: return nil
        }
    }
}

extension MainScreenCollectionView {
    
    struct Item: Hashable {
        let title: String
        let posterPath: String?
        let id: Int
        let section: Categories
    }
    
    enum Section: String {
        case nowPlayingMovies = "Now Playing"
        case upcomingMovies = "Upcoming"
        case topRatedMovies = "Top Rated"
        case popularMovies = "Popular"
        
        static func sectionToInt(section: Self) -> Int {
            switch section {
            case .nowPlayingMovies: return 0
            case .upcomingMovies: return 1
            case .topRatedMovies: return 2
            case .popularMovies: return 3
            }
        }
        
        static func intToSection(section: Int) -> Self? {
            switch section {
            case 0: return .nowPlayingMovies
            case 1: return .upcomingMovies
            case 2: return .topRatedMovies
            case 3: return .popularMovies
            default: return nil
            }
        }
    }
    
    
}



