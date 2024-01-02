//
//  MainViewModel.swift
//  MoviesApp
//
//  Created by Любомир  Чорняк on 23.08.2023.
//

import UIKit
import Combine

protocol MainViewModelProtocol: AnyObject {
    
    var errorPublisher: Published<String>.Publisher { get }
    
    typealias Item = MainScreenCollectionView.Item
    var nowPlayingMoviesPublisher: Published<[Item]?>.Publisher { get }
    var upcomingMoviesPublisher: Published<[Item]?>.Publisher { get }
    var topRatedMoviesPublisher: Published<[Item]?>.Publisher { get }
    var popularMoviesPublisher:Published<[Item]?>.Publisher { get }
    
    func fetchAllMovies()
    
    var isNowPlayingPaginating: Bool { get }
    var isUpcomingPaginating: Bool { get }
    var isTopRatedPaginating: Bool { get }
    var isPopularPaginating: Bool { get }
    
    func fetchNowPlayingMovies(page: Int)
    func fetchUpcomingMovies(page: Int)
    func fetchTopRatedMovies(page: Int)
    func fetchPopularMovies(page: Int)
}

final class MainViewModel: MainViewModelProtocol {
        
    private let networkManager: NetworkManagerProtocol
    
    @Published private var error: String = ""
    var errorPublisher: Published<String>.Publisher { $error }
    
    @Published private var nowPlayingMovies: [Item]?
    var nowPlayingMoviesPublisher: Published<[Item]?>.Publisher { $nowPlayingMovies }
    
    @Published private var upcomingMovies: [Item]?
    var upcomingMoviesPublisher: Published<[Item]?>.Publisher { $upcomingMovies }
    
    @Published private var topRatedMovies: [Item]?
    var topRatedMoviesPublisher: Published<[Item]?>.Publisher { $topRatedMovies }
    
    @Published private var popularMovies: [Item]?
    var popularMoviesPublisher:Published<[Item]?>.Publisher { $popularMovies }
    
    init(networkManager: NetworkManagerProtocol) {
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
                let model: MovieModel = try await networkManager.fetch(Endpoint.movieNowPlaying(page: page))
                var movies: [Item] = []
                for movie in model.results {
                    movies.append(.init(title: movie.title, posterPath: movie.posterPath, id: movie.id, section: .nowPlayingMovies))
                }
                let sendableMovies = movies
                await MainActor.run {
                    self.nowPlayingMovies = sendableMovies
                }
                isNowPlayingPaginating = false
            } catch {
                await MainActor.run {
                    self.error = error.localizedDescription
                }
            }
        }
    }
    
    public func fetchUpcomingMovies(page: Int) {
        Task {
            isUpcomingPaginating = true
            
            do {
                let model: MovieModel = try await networkManager.fetch(Endpoint.movieUpcoming(page: page))
                var movies: [Item] = []
                for movie in model.results {
                    movies.append(.init(title: movie.title, posterPath: movie.posterPath, id: movie.id, section: .upcomingMovies))
                }
                let sendableMovies = movies
                await MainActor.run {
                    self.upcomingMovies = sendableMovies
                }
                isUpcomingPaginating = false
            } catch {
                await MainActor.run {
                    self.error = error.localizedDescription

                }
            }
        }
    }
    
    public func fetchTopRatedMovies(page: Int) {
        Task {
            isTopRatedPaginating = true
            
            do {
                let model: MovieModel = try await networkManager.fetch(Endpoint.movieTopRated(page: page))
                var movies: [Item] = []
                for movie in model.results {
                    movies.append(.init(title: movie.title, posterPath: movie.posterPath, id: movie.id, section: .topRatedMovies))
                }
                let sendableMovies = movies
                await MainActor.run {
                    self.topRatedMovies = sendableMovies
                }
                isTopRatedPaginating = false
            } catch {
                await MainActor.run {
                    self.error = error.localizedDescription

                }
            }
        }
    }
    
    public func fetchPopularMovies(page: Int)  {
        Task {
            isPopularPaginating = true
            
            do {
                let model: MovieModel = try await networkManager.fetch(Endpoint.moviePopular(page: page))
                var movies: [Item] = []
                for movie in model.results {
                    movies.append(.init(title: movie.title, posterPath: movie.posterPath, id: movie.id, section: .popularMovies))
                }
                let sendableMovies = movies
                await MainActor.run {
                    self.popularMovies = sendableMovies
                }
                isPopularPaginating = false
            } catch {
                await MainActor.run {
                    self.error = error.localizedDescription

                }
            }
        }
    }

}
