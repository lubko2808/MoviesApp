//
//  Decade.swift
//  MoviesApp
//
//  Created by Любомир  Чорняк on 23.12.2023.
//

import Foundation

enum Decade: String, CaseIterable {
    case anyDecade = "Any"
    case decade1920s = "1920s"
    case decade1930s = "1930s"
    case decade1940s = "1940s"
    case decade1950s = "1950s"
    case decade1960s = "1960s"
    case decade1970s = "1970s"
    case decade1980s = "1980s"
    case decade1990s = "1990s"
    case decade2000s = "2000s"
    case decade2010s = "2010s"
    case decade2020s = "2020s"
    
    var years: [Int] {
        var years = [Int]()
        let decade = self.rawValue
        if let firstCharacter = decade.first, let digit = Int(String(firstCharacter)) {
            for i in 0..<10 {
                years.append(digit + i)
            }
        }
        return []
    }
}
