//
//  MovieListsCoordinator.swift
//  MoviesApp
//
//  Created by Lubomyr Chorniak on 29.12.2023.
//

import UIKit

class MovieListsCoordinator: Coordinator {
    var navigationController: UINavigationController
    
    var childCoordinators = [Coordinator]()
    
    let screenFactory = ScreenFactory()
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        let controller = screenFactory.createMovieListsScreen()
        controller.onMovieCellTapped = { [weak self] movieId, poster in
            self?.showDetailScreen(movieId: movieId, poster: poster)
        }
        navigationController.pushViewController(controller, animated: true)
    }
    
    private func showDetailScreen(movieId: Int, poster: UIImage) {
        let controller = screenFactory.createDetailScreen(movieId: movieId, moviePoster: poster)
        controller.completionHandler = { [weak self] in
            self?.navigationController.dismiss(animated: true)
        }
        navigationController.present(controller, animated: true)
    }
    
}

