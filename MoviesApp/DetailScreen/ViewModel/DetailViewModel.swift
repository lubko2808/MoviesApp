//
//  DetailViewModel.swift
//  MoviesApp
//
//  Created by Любомир  Чорняк on 28.08.2023.
//

import Foundation

protocol DetailViewModelProtocol: AnyObject {
    
    var errorPublisher: Published<String>.Publisher { get }
    
    var extendedMovieInfoPublisher: Published<ExtendedMovieModel?>.Publisher { get }
    var overviewPublisher: Published<String>.Publisher { get }
    var castPublisher: Published<[Actor]>.Publisher { get }
    var trailersPublisher: Published<[Trailer]>.Publisher { get }
    var reviewsPublisher: Published<[Review]>.Publisher { get }
 
    func fetchInfo(id: Int)
    
}

final class DetailViewModel: DetailViewModelProtocol {
    
    private let networkManager: NetworkManagerProtocol
    
    init(networkManager: NetworkManagerProtocol) {
        self.networkManager = networkManager
    }
    
    @Published var error = ""
    var errorPublisher: Published<String>.Publisher { $error }
    
    @Published var extendedMovieInfo: ExtendedMovieModel? = nil
    var extendedMovieInfoPublisher: Published<ExtendedMovieModel?>.Publisher { $extendedMovieInfo }
    
    @Published var overview = ""
    var overviewPublisher: Published<String>.Publisher { $overview }
    
    @Published var cast: [Actor] = []
    var castPublisher: Published<[Actor]>.Publisher { $cast }
    
    @Published var trailers: [Trailer] = []
    var trailersPublisher: Published<[Trailer]>.Publisher { $trailers }
    
    @Published var reviews: [Review] = []
    var reviewsPublisher: Published<[Review]>.Publisher { $reviews }

    public func fetchInfo(id: Int) {
        Task {
            do {
                try await withThrowingTaskGroup(of: Void.self) { group in
                    group.addTask {
                        try await self.fetchMovieInfo(id: id)
                    }
                    group.addTask {
                        try await self.fetchCast(id: id)
                    }
                    group.addTask {
                        try await self.fetchTrailers(id: id)
                    }
                    group.addTask {
                        try await self.fetchReviews(id: id)
                    }

                    for try await _ in group {}
                }
            } catch {
                await MainActor.run {
                    self.error = error.localizedDescription
                }
            }
        }
        
    }
    
    private func fetchMovieInfo(id: Int) async throws {
        let model: ExtendedMovieModel = try await networkManager.fetch(Endpoint.movieInfo(id: id))
        await MainActor.run {
            self.extendedMovieInfo = model
            self.overview = model.overview
        }
    }
    
    private func fetchCast(id: Int) async throws {
        let model: MovieCastModel = try await networkManager.fetch(Endpoint.movieCast(id: id))
        let setOfActors = Set(model.cast)
        let uniqueActors = Array(setOfActors)
        await MainActor.run {
            self.cast = uniqueActors
        }
    }
    
    private func fetchTrailers(id: Int) async throws {
        let model: MovieTrailersModel = try await networkManager.fetch(Endpoint.movieTrailers(id: id))
        let setOfTrailers = Set(model.results)
        let uniqueTrailers = Array(setOfTrailers)
        await MainActor.run {
            self.trailers = uniqueTrailers
        }
    }
    
    private func fetchReviews(id: Int) async throws {
        let model: MovieReviewsModel = try await networkManager.fetch(Endpoint.movieReviews(id: id))
        let setOfComments = Set(model.results)
        let uniqueComments = Array(setOfComments)
        await MainActor.run {
            self.reviews = uniqueComments
        }
    }
}
