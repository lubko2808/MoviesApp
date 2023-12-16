//
//  TagCollectionViewCell.swift
//  MoviesApp
//
//  Created by Любомир  Чорняк on 16.12.2023.
//

import UIKit

class TagCollectionViewCell: UICollectionViewCell {

    let tagLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    let deleteButton: CustomButton = {
        let button = CustomButton()
        let image = UIImage(systemName: "trash.circle.fill")
        button.setImage(image, for: .normal)
        button.backgroundColor = .red
        button.tintColor = .white
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(tagLabel)
        contentView.addSubview(deleteButton)
        contentView.backgroundColor = UIColor.gray.withAlphaComponent(0.6)
        contentView.layer.cornerRadius = 8
        contentView.clipsToBounds = true
        contentView.layer.borderColor = UIColor.gray.cgColor
        contentView.layer.borderWidth = 1
        self.tagLabel.textColor = .white

        setConstraints()
    }


    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setConstraints() {
        tagLabel.snp.makeConstraints { make in
            make.leading.top.bottom.equalToSuperview().inset(5)
        }

        deleteButton.snp.makeConstraints { make in
            make.leading.equalTo(tagLabel.snp.trailing).offset(10)
            make.top.bottom.trailing.equalToSuperview()
        }
    }

}

class CustomButton: UIButton {
    var item : Int = 0
}
