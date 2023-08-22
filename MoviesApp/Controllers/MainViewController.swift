//
//  ViewController.swift
//  MoviesApp
//
//  Created by Любомир  Чорняк on 13.08.2023.
//

import UIKit

class MainViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        let cell = MainCollectionViewCell(frame: CGRect(x: 40, y: 300, width: 300, height: 400))
        view.addSubview(cell)
        cell.configureCell(with: UIImage(named: "image"), movieTitle: "Movie")
        
    }

    

}

