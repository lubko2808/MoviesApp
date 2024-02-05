//
//  UIViewController+Extension.swift
//  MoviesApp
//
//  Created by Lubomyr Chorniak on 24.01.2024.
//

import UIKit

extension UIViewController {
    
    func showError(with message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        self.present(alert, animated: true)
    }
    
}
