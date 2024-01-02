//
//  TabBarCoordinator.swift
//  MoviesApp
//
//  Created by Lubomyr Chorniak on 29.12.2023.
//

import UIKit
import Combine

class TabBarCoordinator: Coordinator {
    
    var navigationController: UINavigationController
    
    var childCoordinators = [Coordinator]()
    
    private var subscriptions = Set<AnyCancellable>()
    
    var tabBarController = TabBarViewController()
        
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        navigationController.pushViewController(tabBarController, animated: true)
        navigationController.navigationBar.isHidden = true
    
        let nav1 = UINavigationController()
        let nav2 = UINavigationController()
        let nav3 = UINavigationController()
        
        
        
        tabBarController.setViewControllers([nav1, nav2, nav3], animated: true)
        
        showMainScreen(navigationController: nav1)
        showSearchScreen(navigationController: nav2)
        showMovieListsScreen(navigationController: nav3)
    }
    
    private func showMainScreen(navigationController: UINavigationController) {
        let mainCoordinator = MainCoordinator(navigationController: navigationController)
        mainCoordinator.didPresentOrDismissDetailViewController
            .sink { [weak self] _ in
                self?.tabBarController.changeTabBarVisibility()
            }
            .store(in: &subscriptions)
        
        childCoordinators.append(mainCoordinator)
        mainCoordinator.start()
    }
    
    private func showSearchScreen(navigationController: UINavigationController) {
        let searchCoordinator = SearchCoordinator(navigationController: navigationController)
        childCoordinators.append(searchCoordinator)
        searchCoordinator.start()
    }
    
    private func showMovieListsScreen(navigationController: UINavigationController) {
        let movieListsCoordinator = MovieListsCoordinator(navigationController: navigationController)
        childCoordinators.append(movieListsCoordinator)
        movieListsCoordinator.start()
    }
    
    
    
    
}
