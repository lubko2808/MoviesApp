//
//  CoreDataManager.swift
//  MoviesApp
//
//  Created by Любомир  Чорняк on 03.09.2023.
//

import Foundation
import CoreData
import UIKit

protocol CoreDataManagerProtocol: AnyObject {
    
    func createMovieList(name: String)
    func addMovieToLists(_ lists: [MovieList], title: String, poster: UIImage?, id: Int)
    func fetchMovies(filter: String?) -> [Movie]
    func fetchMovies(in list: String) -> [Movie]?
    func isListInStorage(_ listName: String) -> Bool
    func fetchMovieLists(filter: String?) -> [MovieList]
    func fetchListsInWhichMovieIsStored(movieId: Int) -> [MovieList]
    func fetchListsInWhichMovieIsNotStored(movieId: Int) -> [MovieList]
    func deleteMovieFromLists(_ lists: [MovieList], movieId: Int)
    func deleteMovieFromLists(listNames: [String], movieId: Int)
    func fetchMovie(with id: Int) -> Movie?
    func deleteMovie(_ movie: Movie)
    func deleteMovieList(_ movieList: MovieList)
    
}

extension CoreDataManagerProtocol {
    func fetchMovieLists() -> [MovieList] {
        fetchMovieLists(filter: nil)
    }
}

final class CoreDataManager: CoreDataManagerProtocol {

    private let persistentContainer: NSPersistentContainer
    private var viewContext: NSManagedObjectContext {
        persistentContainer.viewContext
    }

    init(persistentContainer: NSPersistentContainer) {
        self.persistentContainer = persistentContainer
    }
    
    private func save() {
        if viewContext.hasChanges {
            do {
                try viewContext.save()
            } catch {
                print("An error occurred while saving: \(error.localizedDescription)")
            }
        }
    }
    
}

extension CoreDataManager {
    
    func createMovieList(name: String) {
        let movieList = MovieList(context: viewContext)
        movieList.movies = []
        movieList.name = name
        save()
    }
    
    func addMovieToLists(_ lists: [MovieList], title: String, poster: UIImage?, id: Int) {
        if let movie = fetchMovie(with: id) {
            for list in lists {
                list.addToMovies(movie)
            }
        } else {
            let movie = Movie(context: viewContext)
            movie.title = title
            movie.poster = poster?.pngData()
            movie.id = Int64(id)
            movie.dateAdded = Date()
            for list in lists {
                list.addToMovies(movie)
            }
        }
        save()
    }
    
    func fetchMovies(filter: String? = nil) -> [Movie] {
        let request: NSFetchRequest<Movie> = Movie.fetchRequest()
        let sortDescriptor = NSSortDescriptor(keyPath: \Movie.dateAdded, ascending: false)
        request.sortDescriptors = [sortDescriptor]
        
        if let filter {
            let predicate = NSPredicate(format: "title contains[cd] %@", filter)
            request.predicate = predicate
        }
        
        do {
            return try viewContext.fetch(request)
        } catch {
            print(error.localizedDescription)
            return []
        }
    }
    
    func fetchMovies(in list: String) -> [Movie]? {
        let lists = fetchMovieLists()
        
        for element in lists {
            if element.name == list {
                guard let movies = element.movies.map( {$0} ) as? [Movie] else {
                    return nil
                }
                return movies.sorted {$0.dateAdded < $1.dateAdded}
            }
        }

        return nil
    }
    
    func isListInStorage(_ listName: String) -> Bool {
        let lists = fetchMovieLists()
        for list in lists {
            if list.name == listName {
                return true
            }
        }
        return false
    }
    
    func fetchMovieLists(filter: String? = nil) -> [MovieList] {
        let request: NSFetchRequest<MovieList> = MovieList.fetchRequest()
        //let sortDescriptor = NSSortDescriptor(keyPath: \MovieList.name, ascending: false)
        //request.sortDescriptors = [sortDescriptor]
        
        if let filter {
            let predicate = NSPredicate(format: "name contains[cd] %@", filter)
            request.predicate = predicate
        }
        
        do {
            return try viewContext.fetch(request)
        } catch {
            print(error.localizedDescription)
            return []
        }
    }

    func fetchListsInWhichMovieIsStored(movieId: Int) -> [MovieList] {
        var movieLists = fetchMovieLists()
        
        movieLists = movieLists.filter { movieList in
            let movies = movieList.movies.compactMap {$0 as? Movie}

            if movies.first(where: { $0.id == movieId }) == nil {
                return false
            } else {
                return true
            }
        }

        return movieLists
    }
    
    func fetchListsInWhichMovieIsNotStored(movieId: Int) -> [MovieList] {
        var movieLists = fetchMovieLists()
        
        movieLists = movieLists.filter { movieList in
            let movies = movieList.movies.compactMap {$0 as? Movie}

            if movies.first(where: { $0.id == movieId }) == nil {
                return true
            } else {
                return false
            }
        }

        return movieLists
    }
    
    func deleteMovieFromLists(_ lists: [MovieList], movieId: Int) {

        guard let movieToDelete = fetchMovie(with: movieId)  else { return }

        for i in 0..<lists.count {
            lists[i].removeFromMovies(movieToDelete)
        }

        if fetchListsInWhichMovieIsStored(movieId: movieId).isEmpty {
            deleteMovie(movieToDelete)
        }
        save()
    }
    
    func deleteMovieFromLists(listNames: [String], movieId: Int) {
       
        guard let movieToDelete = fetchMovie(with: movieId)  else { return }
       
        let lists = fetchMovieLists().filter { movieList in
            if listNames.contains(movieList.name) {
                return true
            } else {
                return false
            }
        }
        
        for i in 0..<lists.count {
            lists[i].removeFromMovies(movieToDelete)
        }
        
        if fetchListsInWhichMovieIsStored(movieId: movieId).isEmpty {
            deleteMovie(movieToDelete)
        }

        save()
    }
    
    func fetchMovie(with id: Int) -> Movie? {
        let lists = fetchMovieLists()
        
        for list in lists {
            guard let movies = list.movies.map( {$0} ) as? [Movie] else {
                return nil
            }
            if let movie = movies.first(where: { $0.id == id }) { return movie }
        }
        
        return nil
    }
    
    func deleteMovie(_ movie: Movie) {
        viewContext.delete(movie)
        save()
    }
    
    func deleteMovieList(_ movieList: MovieList) {
        movieList.movies = []
        viewContext.delete(movieList)
        save()
    }
    
}
