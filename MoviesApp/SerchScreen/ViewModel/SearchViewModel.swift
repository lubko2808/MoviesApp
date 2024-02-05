//
//  SearchViewModel.swift
//  MoviesApp
//
//  Created by Любомир  Чорняк on 21.12.2023.
//

import Foundation
import Combine

protocol SearchViewModelProtocol: AnyObject {

    var errorPublisher: Published<String>.Publisher { get }
    var moviesPublisher: Published<[MovieInfo]>.Publisher { get }
    
    var query: String { get set }
    var genre: Genre  { get set }
    var rating: String? { get set }
    var totalVotes: String? { get set }
    var decade: Decade? { get set }
    var year: String? { get set }
    var includeAdult: Bool { get set }
    var primaryLanguage: PrimaryLanguage? { get set }
    
    var isPaginating: Bool { get set }
    
    func cancelTask()
    
    func searchMovies(startFromBeginning: Bool)
    func fetchListsInWhichMovieIsStored(moviedId: Int) -> [MovieList]
        
}

final class SearchViewModel: SearchViewModelProtocol {

    private let networkManager: NetworkManagerProtocol
    private let coreDataManager: CoreDataManagerProtocol

    init(networkManager: NetworkManagerProtocol, coreDataManager: CoreDataManagerProtocol) {
        self.networkManager = networkManager
        self.coreDataManager = coreDataManager
    }
    
    public func fetchListsInWhichMovieIsStored(moviedId: Int) -> [MovieList] {
        coreDataManager.fetchListsInWhichMovieIsStored(movieId: moviedId)
    }

    @Published private var error: String = ""
    var errorPublisher: Published<String>.Publisher { $error }
    
    @Published private var movies: [MovieInfo] = []
    var moviesPublisher: Published<[MovieInfo]>.Publisher { $movies }
    
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
    
    public func cancelTask() {
        task?.cancel()
    }
    
    private var task: Task<Void, Error>?
    
    // MARK: - Search
    
    private var allMovies: [SearchMovieInfo] = []
    private var filteredMovies: [SearchMovieInfo] = []
    private var tempMovies: [SearchMovieInfo] = []
    
    @MainActor
    public func searchMovies(startFromBeginning: Bool) {
        task?.cancel()
        if startFromBeginning { page = 1 }
        isPaginating = true
        task = Task {
            filteredMovies = []
            do {
                while true {
//                    if query == "" {
//                        self.movies = []
//                        return
//                    }
                    
                    let model: SearchMovieModel = try await networkManager.fetch(Endpoint.movieSearch(
                        query: query, page: page,
                        isAdultIncluded: includeAdult,
                        year: year)
                    )
                    
                    
                    let totalPages = model.totalPages
                    allMovies = model.results
                    tempMovies = []
                    filterBasedOnGenre()
                    filterBasedOnRating()
                    filterBasedOnTotalVotes()
                    filterBasedOnDecade()
                    filterBasedOnPrimaryLanguage()
                    
                    page += 1

                    filteredMovies.append(contentsOf: tempMovies)
                    guard filteredMovies.count <= 5 else {
                        let movies = filteredMovies.map {MovieInfo(title: $0.title, posterPath: $0.posterPath, id: $0.id)}
                        self.isPaginating = false
                        self.movies = movies
                        return
                    }
                    
                    if page > totalPages {
                        let movies = filteredMovies.map { MovieInfo(title: $0.title, posterPath: $0.posterPath, id: $0.id) }
                        self.movies = movies
                        return
                    }
                    
                }
            } catch let error as NSError {
                if !(error.domain == NSURLErrorDomain && error.code == -999) {
                    self.error = error.localizedDescription
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


extension SearchViewModel {
    
    private func printValues() {
        print("genre: \(genre.rawValue)")
        print("rating: \(String(describing: rating))")
        print("totalVotes: \(String(describing: totalVotes))")
        print("decade: \(String(describing: decade?.rawValue))")
        print("year: \(String(describing: year))")
        print("includeAdult: \(includeAdult)")
        print("primaryLanguage: \(String(describing: primaryLanguage))")
    }
    
}
