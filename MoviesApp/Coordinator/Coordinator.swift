//
//  Coordinator.swift
//  MoviesApp
//
//  Created by Lubomyr Chorniak on 29.12.2023.
//

import UIKit

protocol Coordinator: AnyObject {
    
    var navigationController: UINavigationController { get set }
    
    var childCoordinators: [Coordinator] { get set }
    
    func start()
    
}

