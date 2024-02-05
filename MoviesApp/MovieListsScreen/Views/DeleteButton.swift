//
//  DeleteButton.swift
//  MoviesApp
//
//  Created by Lubomyr Chorniak on 05.02.2024.
//

import UIKit

class DeleteButton: UIButton {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .white
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowRadius = 5
        self.layer.shadowOffset = CGSize(width: 5, height: 5)
        self.layer.shadowOpacity = 1
        self.layer.cornerRadius = 20
        self.isHidden = true
        self.setTitle("Delete", for: .normal)
        self.setTitleColor(.black, for: .normal)
        self.translatesAutoresizingMaskIntoConstraints = false
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
