//
//  CoreDataManager.swift
//  MoviesApp
//
//  Created by Любомир  Чорняк on 03.09.2023.
//

import Foundation
import CoreData
import UIKit

class CoreDataManager {
    static let shared = CoreDataManager(modelName: "MoviesApp")
    
    let persistentContainer: NSPersistentContainer
    var viewContext: NSManagedObjectContext {
        persistentContainer.viewContext
    }
    
    private init(modelName: String) {
        persistentContainer = NSPersistentContainer(name: modelName)
    }
    
    func load(completion: (() -> Void)? = nil) {
        persistentContainer.loadPersistentStores { description, error in
            if let error {
                fatalError(error.localizedDescription)
            }
            completion?()
        }
    }
    
    func save() {
        if viewContext.hasChanges {
            do {
                try viewContext.save()
            } catch {
                print("An error occurred while saving: \(error.localizedDescription)")
            }
        }
    }
    
}

// MARK: - Helper functions

extension CoreDataManager {
    
    func createMovieList(name: String) {
        let movieList = MovieList(context: viewContext)
        movieList.movies = []
        movieList.name = name
        save()
    }
    
    func createAndAddMovieToLists(_ lists: [MovieList], title: String, poster: UIImage?, id: Int) {
        let movie = Movie(context: viewContext)
        movie.title = title
        movie.poster = poster?.pngData()
        movie.id = Int64(id)
        movie.dateAdded = Date()
        movie.movieLists = NSSet(array: lists)
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
    
    func isMovieInStorage(movieId: Int) -> Bool {
        let movies = fetchMovies()
        if movies.first(where: { $0.id == movieId }) == nil {
            return false
        } else {
            return true
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
