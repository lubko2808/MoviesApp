//
//  GenreCollectionViewCell.swift
//  MoviesApp
//
//  Created by Любомир  Чорняк on 19.12.2023.
//

import UIKit

class GenreCollectionViewCell: UICollectionViewCell {
        
    private let genreLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 34, weight: .semibold)
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    enum Constants {
        static let defaultBackgroundColor: UIColor =  #colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1)
        static let BackgroundColorWhenSelected: UIColor = #colorLiteral(red: 0.9686274529, green: 0.78039217, blue: 0.3450980484, alpha: 1)
    }
    
    /*
    override var isSelected: Bool {
        set {
            if newValue {
                contentView.backgroundColor = Constants.BackgroundColorWhenSelected
            } else {
                contentView.backgroundColor = Constants.defaultBackgroundColor
            }
        }
        get {
            
            //return self.isSelected
            return true
        }
    }
    */ 
     
    public var isCellSelected: Bool = false {
        didSet {
            if isCellSelected {
                contentView.backgroundColor = Constants.BackgroundColorWhenSelected
            } else {
                contentView.backgroundColor = Constants.defaultBackgroundColor
            }
        }
    }
    
    public func getGenre() -> String {
        genreLabel.text ?? ""
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.layer.cornerRadius = 20
        contentView.layer.masksToBounds = false
        contentView.backgroundColor = Constants.defaultBackgroundColor
        contentView.layer.shadowColor = UIColor.black.cgColor
        contentView.layer.shadowRadius = 5
        contentView.layer.shadowOpacity = 0.8
        contentView.addSubview(genreLabel)
        genreLabel.snp.makeConstraints { make in
            make.trailing.leading.equalTo(contentView).inset(10)
            make.top.bottom.equalTo(contentView).inset(5)
            
        }
        
    }
    
    public func configure(with genre: Genre) {
        genreLabel.text = genre.rawValue
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
