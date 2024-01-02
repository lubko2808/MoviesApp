//
//  TabBarViewController.swift
//  MoviesApp
//
//  Created by Любомир  Чорняк on 22.08.2023.
//

import UIKit
import SnapKit
import RxSwift
import Combine

protocol TabBarViewControllerProtocol {
    func changeTabBarVisibility()
}

class TabBarViewController: UITabBarController, TabBarViewControllerProtocol {
    
    private let customTabBar = CustomTabBar()
    private let disposeBag = DisposeBag()
    private var subscriptions = Set<AnyCancellable>()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        bind()
        view.addSubview(customTabBar)
        customTabBar.translatesAutoresizingMaskIntoConstraints = false
        customTabBar.addShadow()
        self.selectedIndex = 0
        
        customTabBar.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview().inset(24)
            make.height.equalTo(90)
        }
        
        tabBar.isHidden = true
    }
    
    private func selectTabWith(index: Int) {
        self.selectedIndex = index
    }
    
    public func changeTabBarVisibility() {
        UIView.animate(withDuration: 0.5) {
            let opacity = Int(self.customTabBar.layer.opacity)
            self.customTabBar.layer.opacity = opacity == 1 ? 0 : 1
        }
    }
    
    // MARK: - Bindings
    
    private func bind() {
        customTabBar.itemTapped
            .bind { [weak self] in self?.selectTabWith(index: $0) }
            .disposed(by: disposeBag)
    }
}


