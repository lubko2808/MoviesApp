//
//  MovieList+CoreDataProperties.swift
//  MoviesApp
//
//  Created by Любомир  Чорняк on 14.12.2023.
//
//

import Foundation
import CoreData


extension MovieList {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<MovieList> {
        return NSFetchRequest<MovieList>(entityName: "MovieList")
    }

    @NSManaged public var name: String
    @NSManaged public var movies: NSSet

}

// MARK: Generated accessors for movies
extension MovieList {

    @objc(addMoviesObject:)
    @NSManaged public func addToMovies(_ value: Movie)

    @objc(removeMoviesObject:)
    @NSManaged public func removeFromMovies(_ value: Movie)

    @objc(addMovies:)
    @NSManaged public func addToMovies(_ values: NSSet)

    @objc(removeMovies:)
    @NSManaged public func removeFromMovies(_ values: NSSet)

}

extension MovieList : Identifiable {

}
