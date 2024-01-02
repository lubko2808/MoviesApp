//
//  UIImage+Extension.swift
//  MoviesApp
//
//  Created by Любомир  Чорняк on 17.12.2023.
//

import UIKit

extension UIImage {
    static let circleSymbol = UIImage(systemName: "circle")
    static let checkmarkSymbol = UIImage(systemName: "checkmark.circle.fill")
    static let defaultImage = UIImage(systemName: "face.smiling.inverse")!
}

extension UIImage {
    
    func imageWith(newSize: CGSize) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: newSize)
        let image = renderer.image { _ in
            draw(in: CGRect(origin: .zero, size: newSize))
        }
        return image
    }
    
}

extension UIImage {
    
    static func downloadImage(with url: String) async -> UIImage? {
        
        if let image = CacheManager.shared.get(key: url) {
            return image
        } else {
            let image = await NetworkManager().fetchImage(from: url)
            if let image {
                CacheManager.shared.add(key: url, value: image)
            }
            return image
        }
    }
    
}
