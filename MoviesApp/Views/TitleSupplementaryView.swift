//
//  TitleSupplementaryView.swift
//  MoviesApp
//
//  Created by Любомир  Чорняк on 24.08.2023.
//

import UIKit

class TitleSupplementaryView: UICollectionReusableView {
    let label = UILabel()
    static let reuseIdentifier = "title-supplementary-reuse-identifier"

    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    required init?(coder: NSCoder) {
        fatalError()
    }
}

extension TitleSupplementaryView {
    func configure() {
        addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.adjustsFontForContentSizeCategory = true
        let inset = CGFloat(10)
        label.snp.makeConstraints { make in
            make.leading.trailing.top.bottom.equalToSuperview().inset(inset)
        }
        label.font = UIFont.boldSystemFont(ofSize: 30)

    }
}
