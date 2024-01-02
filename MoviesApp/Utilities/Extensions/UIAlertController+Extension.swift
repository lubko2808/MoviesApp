//
//  UIAlertController+Extension.swift
//  MoviesApp
//
//  Created by Lubomyr Chorniak on 31.12.2023.
//

import UIKit

extension UIAlertController {
    
    static func showError(with message: String, on viewController: UIViewController) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        viewController.present(alert, animated: true)
    }
    
}
