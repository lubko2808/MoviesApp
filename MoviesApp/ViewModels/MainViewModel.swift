//
//  MainViewModel.swift
//  MoviesApp
//
//  Created by Любомир  Чорняк on 23.08.2023.
//

import UIKit

class MainViewModel {
    
    private let networkManager: NetworkManager
    
    var error = ObservableObject<String>("")
    
    var nowPlayingMovies = ObservableObject<[MovieItem]>([])
    var upcomingMovies = ObservableObject<[MovieItem]>([])
    var topRatedMovies = ObservableObject<[MovieItem]>([])
    var popularMovies = ObservableObject<[MovieItem]>([])
    
    var posterImage = ObservableObject<(UIImage?, Int)>((nil, 0))
    
    init(networkManager: NetworkManager) {
        self.networkManager = networkManager
    }
    
    public func fetchAllMovies() {
        fetchNowPlayingMovies(page: 1)
        fetchUpcomingMovies(page: 1)
        fetchTopRatedMovies(page: 1)
        fetchPopularMovies(page: 1)
    }

    public var isNowPlayingPaginating = false
    public var isUpcomingPaginating = false
    public var isTopRatedPaginating = false
    public var isPopularPaginating = false
    
    public func fetchNowPlayingMovies(page: Int) {
        Task {
            isNowPlayingPaginating = true
            
            do {
                print("fetching")
                let model: MovieModel = try await networkManager.fetch(.movieNowPlaying(page: page))
                var movies: [MovieItem] = []
                for movie in model.results {
                    movies.append(.init(title: movie.title, posterPath: movie.poster_path, id: movie.id, section: .nowPlayingMovies))
                }
                let sendableMovies = movies
                await MainActor.run {
                    self.nowPlayingMovies.value = sendableMovies
                }
                isNowPlayingPaginating = false
            } catch {
                await MainActor.run {
                    self.error.value = error.localizedDescription
                }
            }
        }
    }
    
    public func fetchUpcomingMovies(page: Int) {
        Task {
            isUpcomingPaginating = true
            
            do {
                let model: MovieModel = try await networkManager.fetch(.movieUpcoming(page: page))
                var movies: [MovieItem] = []
                for movie in model.results {
                    movies.append(.init(title: movie.title, posterPath: movie.poster_path, id: movie.id, section: .upcomingMovies))
                }
                let sendableMovies = movies
                await MainActor.run {
                    self.upcomingMovies.value = sendableMovies
                }
                isUpcomingPaginating = false
            } catch {
                await MainActor.run {
                    self.error.value = error.localizedDescription
                }
            }
        }
    }
    
    public func fetchTopRatedMovies(page: Int) {
        Task {
            isTopRatedPaginating = true
            
            do {
                let model: MovieModel = try await networkManager.fetch(.movieTopRated(page: page))
                var movies: [MovieItem] = []
                for movie in model.results {
                    movies.append(.init(title: movie.title, posterPath: movie.poster_path, id: movie.id, section: .topRatedMovies))
                }
                let sendableMovies = movies
                await MainActor.run {
                    self.topRatedMovies.value = sendableMovies
                }
                isTopRatedPaginating = false
            } catch {
                await MainActor.run {
                    self.error.value = error.localizedDescription
                }
            }
        }
    }
    
    public func fetchPopularMovies(page: Int)  {
        Task {
            isPopularPaginating = true
            
            do {
                let model: MovieModel = try await networkManager.fetch(.moviePopular(page: page))
                var movies: [MovieItem] = []
                for movie in model.results {
                    movies.append(.init(title: movie.title, posterPath: movie.poster_path, id: movie.id, section: .popularMovies))
                }
                let sendableMovies = movies
                await MainActor.run {
                    self.popularMovies.value = sendableMovies
                }
                isPopularPaginating = false
            } catch {
                await MainActor.run {
                    self.error.value = error.localizedDescription
                }
            }
        }
    }

    
    

}
