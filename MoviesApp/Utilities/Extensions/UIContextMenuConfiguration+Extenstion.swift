//
//  UIContextMenuConfiguration+Extenstion.swift
//  MoviesApp
//
//  Created by Lubomyr Chorniak on 31.12.2023.
//

import UIKit

extension UIContextMenuConfiguration {

    @MainActor
    convenience init(listsInWhichMovieIsStored: [MovieList],
                     title: String,
                     poster: UIImage?,
                     id: Int,
                     onListActionTapped: ((String, UIImage?, Int, ActionType) -> Void)? ) {
        
        self.init(identifier: nil, previewProvider: nil) { _ in
            var menu: UIMenu?
            
            // MARK: - share action
            let share = UIAction(
                title: "Share",
                state: .off
            ) { _ in }
            
            // MARK: - add/remove movies action
            
            let addToList = UIAction(
                title: "Add To List",
                image: UIImage(systemName: "plus"),
                state: .off
            ) { _ in
                onListActionTapped?(title, poster, id, .add)
            }
            
            let removeFromLists = UIAction(
                title: "Remove From Lists",
                image: UIImage(systemName: "delete.left"),
                state: .off
            ) { _ in
                onListActionTapped?(title, poster, id, .remove)
            }

            if !listsInWhichMovieIsStored.isEmpty {
                menu = UIMenu(title: "Actions", identifier: nil, options: UIMenu.Options.displayInline, children: [share, addToList, removeFromLists])
            } else {
                menu = UIMenu(title: "Actions", identifier: nil, options: UIMenu.Options.displayInline, children: [share, addToList])
            }
            
            return menu
        }
    }
}

