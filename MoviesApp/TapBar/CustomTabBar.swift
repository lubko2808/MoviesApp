//
//  CustomTabBar.swift
//  MoviesApp
//
//  Created by Любомир  Чорняк on 17.12.2023.
//

import UIKit
import RxSwift
import RxCocoa
import RxGesture

final class CustomTabBar: UIStackView {
    
    var itemTapped: Observable<Int> { itemTappedSubject.asObservable() }
    
    private lazy var customItemViews: [CustomItemView] = [mainItem, searchItem, listsItem]
    
    private let mainItem = CustomItemView(with: .main, index: 0)
    private let searchItem = CustomItemView(with: .search, index: 1)
    private let listsItem = CustomItemView(with: .lists, index: 2)
    
    private let itemTappedSubject = PublishSubject<Int>()
    private let disposeBag = DisposeBag()
    
    init() {
        super.init(frame: .zero)
        [mainItem, searchItem, listsItem].forEach { self.addArrangedSubview($0) }
        distribution = .fillEqually
        alignment = .center
        backgroundColor = UIColor.systemIndigo.withAlphaComponent(0.8)
        setupCornerRadius(30)
        customItemViews.forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.clipsToBounds = true
        }
        
        bind()
        
        setNeedsLayout()
        layoutIfNeeded()
        selectItem(index: 0)
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func selectItem(index: Int) {
        customItemViews.forEach { $0.isSelected = $0.index == index }
        itemTappedSubject.onNext(index)
    }
    
    //MARK: - Bindings
    
    private func bind() {
        mainItem.rx.tapGesture()
            .when(.recognized)
            .bind { [weak self] _ in
                guard let self = self else { return }
                self.mainItem.animateClick {
                    self.selectItem(index: self.mainItem.index)
                }
            }
            .disposed(by: disposeBag)
        
        searchItem.rx.tapGesture()
            .when(.recognized)
            .bind { [weak self] _ in
                guard let self = self else { return }
                self.searchItem.animateClick {
                    self.selectItem(index: self.searchItem.index)
                }
            }
            .disposed(by: disposeBag)
        
        listsItem.rx.tapGesture()
            .when(.recognized)
            .bind { [weak self] _ in
                guard let self = self else { return }
                self.listsItem.animateClick {
                    self.selectItem(index: self.listsItem.index)
                }
            }
            .disposed(by: disposeBag)
    }
}


