//
//  CustomTabItem.swift
//  MoviesApp
//
//  Created by Любомир  Чорняк on 17.12.2023.
//

import UIKit

enum CustomTabItem: String, CaseIterable {
    case main
    case search
    case lists
}
 
extension CustomTabItem {
    
    var icon: UIImage? {
        switch self {
        case .main:
            return UIImage(systemName: "house.circle")?.withTintColor(.white.withAlphaComponent(0.4), renderingMode: .alwaysOriginal)
        case .search:
            return UIImage(systemName: "magnifyingglass.circle")?.withTintColor(.white.withAlphaComponent(0.4), renderingMode: .alwaysOriginal)
        case .lists:
            return UIImage(systemName: "list.bullet.circle")?.withTintColor(.white.withAlphaComponent(0.4), renderingMode: .alwaysOriginal)
        }
    }
    
    var selectedIcon: UIImage? {
        switch self {
        case .main:
            return UIImage(systemName: "house.circle.fill")?.withTintColor(.white, renderingMode: .alwaysOriginal)
        case .search:
            return UIImage(systemName: "magnifyingglass.circle.fill")?.withTintColor(.white, renderingMode: .alwaysOriginal)
        case .lists:
            return UIImage(systemName: "list.bullet.circle.fill")?.withTintColor(.white, renderingMode: .alwaysOriginal)
        }
    }
    
    var name: String {
        return self.rawValue.capitalized
    }
}

