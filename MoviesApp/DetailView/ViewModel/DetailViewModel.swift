//
//  DetailViewModel.swift
//  MoviesApp
//
//  Created by Любомир  Чорняк on 28.08.2023.
//

import Foundation

class DetailViewModel {
    
    private let networkManager: NetworkManager
    
    init(networkManager: NetworkManager) {
        self.networkManager = networkManager
    }
    
    @Published var error = ""
    
    @Published var extendedMovieInfo: ExtendedMovieModel? = nil
    @Published var overview = ""
    @Published var cast: [Actor] = []
    @Published var trailers: [Trailer] = []
    @Published var reviews: [Review] = []

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
        let model: ExtendedMovieModel = try await networkManager.fetch(.movieInfo(id: id))
        await MainActor.run {
            self.extendedMovieInfo = model
            self.overview = model.overview
        }
    }
    
    
    private func fetchCast(id: Int) async throws {
        let model: MovieCastModel = try await networkManager.fetch(.movieCast(id: id))
        let setOfActors = Set(model.cast)
        let uniqueActors = Array(setOfActors)
        await MainActor.run {
            self.cast = uniqueActors
        }
    }
    
    
    
    private func fetchTrailers(id: Int) async throws {
        let model: MovieTrailersModel = try await networkManager.fetch(.movieTrailers(id: id))
        let setOfTrailers = Set(model.results)
        let uniqueTrailers = Array(setOfTrailers)
        await MainActor.run {
            self.trailers = uniqueTrailers
        }
    }
    
    
    
    private func fetchReviews(id: Int) async throws {
        let model: MovieReviewsModel = try await networkManager.fetch(.movieReviews(id: id))
        let setOfComments = Set(model.results)
        let uniqueComments = Array(setOfComments)
        await MainActor.run {
            self.reviews = uniqueComments
        }
    }
}
