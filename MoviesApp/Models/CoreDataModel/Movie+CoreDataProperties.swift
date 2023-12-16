//
//  Movie+CoreDataProperties.swift
//  MoviesApp
//
//  Created by Любомир  Чорняк on 03.09.2023.
//
//

import Foundation
import CoreData


extension Movie {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Movie> {
        return NSFetchRequest<Movie>(entityName: "Movie")
    }

    @NSManaged public var dateAdded: Date
    @NSManaged public var poster: Data?
    @NSManaged public var title: String
    @NSManaged public var id: Int64
    @NSManaged public var movieLists: NSSet

}

extension Movie : Identifiable {

}
