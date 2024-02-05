//
//  ScreenFactory.swift
//  MoviesApp
//
//  Created by Lubomyr Chorniak on 31.12.2023.
//

import UIKit

class ScreenFactory {
    
    func createMainScreen() -> MainViewController {
        let networkManager = NetworkManager()
        let viewModel = MainViewModel(networkManager: networkManager)
        let persistenceContainer = AppDelegate.shared.presistenceContainer!
        let coreDataManager = CoreDataManager(persistentContainer: persistenceContainer)
        let controller = MainViewController(viewModel: viewModel, coreDataManager: coreDataManager)
        return controller
    }
    
    func createSearchScreen() -> SearchViewController {
        let persistenceContainer = AppDelegate.shared.presistenceContainer!
        let coreDataManager = CoreDataManager(persistentContainer: persistenceContainer)
        let viewModel = SearchViewModel(networkManager: NetworkManager(), coreDataManager: coreDataManager)
        let controller = SearchViewController(viewModel: viewModel)
        return controller
    }
    
    func createMovieListsScreen() -> MovieListsViewController {
        let persistenceContainer = AppDelegate.shared.presistenceContainer!
        let coreDataManager = CoreDataManager(persistentContainer: persistenceContainer)
        let controller = MovieListsViewController(coreDataManager: coreDataManager)
        return controller
    }
    
    func createDetailScreen(movieId: Int, moviePoster: UIImage) -> DetailViewController {
        let viewModel = DetailViewModel(networkManager: NetworkManager())
        return DetailViewController(movieId: movieId, moviePoster: moviePoster, viewModel: viewModel)
    }
    
    func createListsViewController(title: String, poster: UIImage?, id: Int, type: ActionType) -> ListsViewController {
        let persistenceContainer = AppDelegate.shared.presistenceContainer!
        let coreDataManager = CoreDataManager(persistentContainer: persistenceContainer)
        let controller = ListsViewController(movieTitle: title, movieImage: poster, movieId: id, type: type, coreDataManager: coreDataManager)
        return controller
    }
    
    func createAdvancedSearchScreen(searchParamters: AdvancedSearchModel) -> AdvancedSearchViewController {
        let controller = AdvancedSearchViewController()
        controller.configure(with: searchParamters)
        return controller
    }
    
}
