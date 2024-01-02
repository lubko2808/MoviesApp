//
//  MainCoordinator.swift
//  MoviesApp
//
//  Created by Lubomyr Chorniak on 29.12.2023.
//

import UIKit
import Combine

class MainCoordinator: Coordinator {
    var navigationController: UINavigationController
    
    var childCoordinators = [Coordinator]()
    
    let transitionManager = TransitionManager()
    let screenFactory = ScreenFactory()
    public let didPresentOrDismissDetailViewController = PassthroughSubject<Void, Never>()
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        let controller = screenFactory.createMainScreen()
        controller.onMovieCellTapped = { [weak self] movieId, poster in
            self?.showDeatilScreen(movieId: movieId, poster: poster)
        }
        
        controller.onListActionTapped = { [weak self] title, poster, id, type in
            self?.showListsViewController(title: title, poster: poster, id: id, type: type)
        }
        navigationController.pushViewController(controller, animated: true)
        
    }
    
    private func showDeatilScreen(movieId: Int, poster: UIImage) {
        let controller = screenFactory.createDetailScreen(movieId: movieId, moviePoster: poster)
        controller.completionHandler = { [weak self] in
            self?.navigationController.dismiss(animated: true)
            self?.didPresentOrDismissDetailViewController.send()
        }
        
        controller.modalPresentationStyle = .overCurrentContext
        controller.transitioningDelegate = transitionManager
        navigationController.present(controller, animated: true)
        didPresentOrDismissDetailViewController.send()
        CFRunLoopWakeUp(CFRunLoopGetCurrent())
    }
    
    private func showListsViewController(title: String, poster: UIImage?, id: Int, type: ActionType) {
        let controller = screenFactory.createListsViewController(title: title, poster: poster, id: id, type: type)
    
        controller.completionHandler = { [weak self] confirmationMessage in
            guard
                let mainViewController = self?.navigationController.viewControllers.filter({ $0 is MainViewController }).first as? MainViewController else { return }
            mainViewController.showPopUp(with: confirmationMessage)
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

