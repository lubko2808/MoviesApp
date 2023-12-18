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

class TabBarViewController: UITabBarController {
    
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
        
        let vc1 = MainViewController()
        vc1.didTransitionSubject
            .sink { [weak self] _ in
                UIView.animate(withDuration: 0.5) {
                    let opacity = Int(self?.customTabBar.layer.opacity ?? 0)
                    self?.customTabBar.layer.opacity = opacity == 1 ? 0 : 1
                }
               
            }
            .store(in: &subscriptions)
        
        let vc2 = SearchViewController()
        let vc3 = MovieListsViewController()
        
        vc1.title = "Main"
        vc2.title = "Search"
        vc3.title = "Lists"
        
        vc1.navigationItem.largeTitleDisplayMode = .always
        vc2.navigationItem.largeTitleDisplayMode = .always
        vc3.navigationItem.largeTitleDisplayMode = .always
        
        let nav1 = UINavigationController(rootViewController: vc1)
        let nav2 = UINavigationController(rootViewController: vc2)
        let nav3 = UINavigationController(rootViewController: vc3)
        
        nav1.navigationBar.prefersLargeTitles = true
        nav2.navigationBar.prefersLargeTitles = true
        nav3.navigationBar.prefersLargeTitles = true
        
        setViewControllers([nav1, nav2, nav3], animated: true)
        
    }
    
    private func selectTabWith(index: Int) {
        self.selectedIndex = index
    }
    
    // MARK: - Bindings
    
    private func bind() {
        customTabBar.itemTapped
            .bind { [weak self] in self?.selectTabWith(index: $0) }
            .disposed(by: disposeBag)
    }
    
}
