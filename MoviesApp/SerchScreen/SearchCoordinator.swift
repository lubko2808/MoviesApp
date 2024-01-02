//
//  SearchCoordinator.swift
//  MoviesApp
//
//  Created by Lubomyr Chorniak on 29.12.2023.
//

import UIKit

class SearchCoordinator: Coordinator {
    var navigationController: UINavigationController
    
    var childCoordinators = [Coordinator]()
    
    let screenFactory = ScreenFactory()

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        let controller = screenFactory.createSearchScreen()
        
        controller.didTapMovieCell = { [weak self] movieId, poster in
            self?.showDetailScreen(movieId: movieId, poster: poster)
        }
        
        controller.didTapAdvancedSearch = { [weak self] searchParameters in
            self?.showAdvancedSearchScreen(searchParameters: searchParameters)
        }
        
        controller.onListActionTapped = { [weak self] title, poster, id, type in
            self?.showListsViewController(title: title, poster: poster, id: id, type: type)
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
    
    private func showAdvancedSearchScreen(searchParameters: AdvancedSearchModel)  {
        guard 
            let searchViewController = navigationController.viewControllers.filter({ $0 is SearchViewController }).first as? SearchViewController else { return }

        let advancedSearchViewController = screenFactory.createAdvancedSearchScreen(searchParamters: searchParameters)
        
        advancedSearchViewController.onClearButtonTapped = {
            searchViewController.setSearchParameters(parameters: AdvancedSearchModel())
        }
        
        advancedSearchViewController.onSearchButtonTapped = { [weak self] searchParameters in
            searchViewController.setSearchParameters(parameters: searchParameters)
            self?.navigationController.dismiss(animated: true)
        }
        
        let controller = UINavigationController(rootViewController: advancedSearchViewController)
        navigationController.present(controller, animated: true)
    }
    
    private func showListsViewController(title: String, poster: UIImage?, id: Int, type: ActionType) {
        
        let controller = screenFactory.createListsViewController(title: title, poster: poster, id: id, type: type)
        
        controller.completionHandler = { [weak self] confirmationMessage in
            guard
                let searchViewController = self?.navigationController.viewControllers.filter({ $0 is SearchViewController }).first as? SearchViewController else { return }
            searchViewController.showPopUp(with: confirmationMessage)
            self?.navigationController.dismiss(animated: true)
        }
        
        let UInavVC = UINavigationController(rootViewController: controller)
        if let sheet = UInavVC.presentationController as? UISheetPresentationController {
            sheet.detents = [.medium(), .large()]
            sheet.largestUndimmedDetentIdentifier = .medium
            sheet.prefersGrabberVisible = true
        }
        
        navigationController.present(UInavVC, animated: true)
    }
    
    
}
