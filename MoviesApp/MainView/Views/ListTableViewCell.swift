//
//  ListTableViewCell.swift
//  MoviesApp
//
//  Created by Любомир  Чорняк on 17.12.2023.
//

import UIKit

class ListTableViewCell: UITableViewCell {

    public func contentViewBackgroundColor() -> UIColor {
        if isCellSelected {
            return #colorLiteral(red: 0.9529411793, green: 0.6862745285, blue: 0.1333333403, alpha: 1)
        } else {
            return UIColor.yellow
        }
    }
    
    var isCellSelected = false
    
    let listNameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 30, weight: .medium)
        label.textColor = #colorLiteral(red: 0.1764705926, green: 0.4980392158, blue: 0.7568627596, alpha: 1)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let checkmarkImageView: UIImageView = {
        let imageView = UIImageView()
        let checkmarkImage = UIImage(systemName: "checkmark")
        checkmarkImage?.applyingSymbolConfiguration(.init(font: .boldSystemFont(ofSize: 40)))
        imageView.image = checkmarkImage
        imageView.tintColor = .blue
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.isHidden = true
        return imageView
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.backgroundColor = .clear
        self.selectionStyle = .none
        contentView.addSubview(listNameLabel)
        contentView.addSubview(checkmarkImageView)
        contentView.layer.cornerRadius = 20
        contentView.layer.masksToBounds = false
        contentView.backgroundColor = .yellow
        
        listNameLabel.snp.makeConstraints { make in
            make.top.bottom.leading.equalToSuperview().inset(8)
            make.trailing.equalTo(checkmarkImageView.snp.leading).offset(-10)
        }
        
        checkmarkImageView.snp.makeConstraints { make in
            make.centerY.equalTo(listNameLabel.snp.centerY)
            make.trailing.equalToSuperview().inset(18)
        }
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.frame = contentView.frame.inset(by: UIEdgeInsets(top: 10, left: 17, bottom: 10, right: 17))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

