//
//  SearchViewModel.swift
//  MoviesApp
//
//  Created by Любомир  Чорняк on 21.12.2023.
//

import Foundation
import Combine

class SearchViewModel {
    
    private let networkManager: NetworkManager

    init(networkManager: NetworkManager) {
        self.networkManager = networkManager
    }

    @Published var error: String = ""
    @Published var movies: [SearchViewController.Item] = []
    
    public var query: String = ""
    public var genre: Genre = .all
    public var rating: String?
    public var totalVotes: String?
    public var decade: Decade?
    public var year: String?
    public var includeAdult = true
    public var primaryLanguage: PrimaryLanguage?
    
    private var page = 1
    
    public var isPaginating = false
    
    private func printValues() {
        print("genre: \(genre.rawValue)")
        print("rating: \(rating)")
        print("totalVotes: \(totalVotes)")
        print("decade: \(decade?.rawValue)")
        print("year: \(year)")
        print("includeAdult: \(includeAdult)")
        print("primaryLanguage: \(primaryLanguage)")
    }
    
    public func cancelTask() {
        task?.cancel()
    }
    
    public var task: Task<Void, Error>?
    // MARK: - Search
    
    private var allMovies: [SearchMovieInfo] = []
    private var filteredMovies: [SearchMovieInfo] = []
    private var tempMovies: [SearchMovieInfo] = []
    public func searchMovies(shouldStartFromBeginning: Bool) {
        task?.cancel()
        if shouldStartFromBeginning { page = 1 }
        print("page: \(page)")
        isPaginating = true
        printValues()
        task = Task {
            filteredMovies = []
            do {
                while true {
                    let model: SearchMovieModel = try await networkManager.fetch(.movieSearch(
                        query: query, page: page,
                        isAdultIncluded: includeAdult,
                        year: year)
                    )
                    let totalPages = model.totalPages
                    allMovies = model.results
                    tempMovies = []
                    filterBasedOnGenre()
                    filterBasedOnRating()
                    print("after rating filtration:")
                    print(filteredMovies)
                    filterBasedOnTotalVotes()
                    print("after total votes filtration:")
                    print(filteredMovies)
                    filterBasedOnDecade()
                    filterBasedOnPrimaryLanguage()
                    
                    page += 1
                    
                    filteredMovies.append(contentsOf: tempMovies)
                    guard filteredMovies.count <= 5 else {
                        let movies = filteredMovies.map { movie in
                            SearchViewController.Item(movie: MovieInfo(title: movie.title, posterPath: movie.posterPath, id: movie.id))
                        }
                        await MainActor.run {
                            self.isPaginating = false
                            self.movies = movies
                        }
                        break
                    }
                    
    
                    if page > totalPages {
                        let movies = filteredMovies.map { movie in
                            SearchViewController.Item(movie: MovieInfo(title: movie.title, posterPath: movie.posterPath, id: movie.id))
                        }
                        await MainActor.run {
                            self.movies = movies 
                        }
                        break
                    }
                    
                }
            } catch let error as NSError {
                if !(error.domain == NSURLErrorDomain && error.code == -999) {
                    await MainActor.run {
                        self.error = error.localizedDescription
                    }
                }
            }
        }
    }
    
    // MARK: - Helpers
    private func convertRatingToDouble() -> Double {
        if let rating {
            if let firstCharacter = rating.first, let digit = Double(String(firstCharacter)) {
                return digit
            }
        }
        return Double()
    }
    
    private func convertTotalVotesToInt() -> Int {
        if let totalVotes {
            switch totalVotes {
            case "1000+":
                return 1000
            case "10 000+":
                return 10_000
            case "100 000":
                return 100_000
            case "1 000 000":
                return 1_000_000
            default:
                return Int()
            }
        }
        return Int()
    }
    
    private func filterBasedOnGenre() {
        if genre == .all {
            tempMovies.append(contentsOf: allMovies)
        } else {
            allMovies.forEach { movie in
                if movie.genreIds.contains(where: {$0 == genre.id }) {
                    tempMovies.append(movie)
                }
            }
        }
    }
    
    private func filterBasedOnRating() {
        if rating != nil {
            let rating = convertRatingToDouble()
            tempMovies.forEach { movie in
                if movie.voteAverage < rating {
                    tempMovies.removeAll {$0 == movie}
                }
            }
        }
    }
    
    private func filterBasedOnTotalVotes() {
        if totalVotes != nil {
            let totalVotes = convertTotalVotesToInt()
            tempMovies.forEach { movie in
                if movie.voteCount < totalVotes {
                    tempMovies.removeAll {$0 == movie}
                }
            }
        }
    }
    
    private func filterBasedOnDecade() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        if let decade, year == nil {
            let years = decade.years
            tempMovies.forEach { movie in
                let dateString = movie.releaseDate
                if let date = dateFormatter.date(from: dateString) {
                    let calendar = Calendar.current
                    let year = calendar.component(.year, from: date)
                    if !years.contains(where: {$0 == year}) {
                        tempMovies.removeAll {$0 == movie}
                    }
                }
            }
        }
     }
    
    private func filterBasedOnPrimaryLanguage() {
        if let primaryLanguage {
            let primaryLanguageString = primaryLanguage.rawValue
            tempMovies.forEach { movie in
                if movie.originalLanguage != primaryLanguageString {
                    tempMovies.removeAll {$0 == movie}
                }
            }
        }
    }
    
}
