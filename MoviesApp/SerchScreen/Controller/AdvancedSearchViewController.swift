//
//  AdvancedSearchViewController.swift
//  MoviesApp
//
//  Created by Любомир  Чорняк on 19.12.2023.
//

import UIKit
import SnapKit
import Combine

struct AdvancedSearchModel {
    let rating: String?
    let totalVotes: String?
    let decade: Decade?
    let year: String?
    let includeAdult: Bool
    let primaryLanguage: PrimaryLanguage?
    
    init(rating: String? = nil, totalVotes: String? = nil, decade: Decade? = nil, year: String? = nil, includeAdult: Bool = true, primaryLanguage: PrimaryLanguage? = nil) {
        self.rating = rating
        self.totalVotes = totalVotes
        self.decade = decade
        self.year = year
        self.includeAdult = includeAdult
        self.primaryLanguage = primaryLanguage
    }
}

class AdvancedSearchViewController: UIViewController {
    
    var onClearButtonTapped: (() -> Void)?
    var onSearchButtonTapped: ((AdvancedSearchModel) -> Void)?

    public func configure(with searchParameters: AdvancedSearchModel) {
        scrollView.configure(with: searchParameters)
    }

    // MARK: - ScrollView
    private var scrollView = AdvancedSearchScrollView()

    
    // MARK: - Bottom views
    private let padView: UIView = {
        let view = UIView()
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.gray.cgColor
        view.backgroundColor = .systemBackground
        return view
    }()
    
    lazy private var clearButton: UIButton = {
        let button = UIButton()
        button.setTitle("CLEAR", for: .normal)
        button.setTitleColor(UIColor.gray, for: .normal)
        button.addTarget(self, action: #selector(clearButtonTapped), for: .touchUpInside)
        button.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        return button
    }()
    
    lazy private var searchButton: UIButton = {
        let button = UIButton()
        button.setTitle("SEARCH", for: .normal)
        button.setTitleColor(UIColor.black, for: .normal)
        button.backgroundColor = .yellow
        button.clipsToBounds = true
        button.layer.cornerRadius = 10
        button.addTarget(self, action: #selector(searchButtonTapped), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupNavigationBar()
        registerForKeyboardNotifications()
    }
    
    private func setupNavigationBar() {
        title = "Advanced Search"
        if let appearance = navigationController?.navigationBar.standardAppearance {
            
            let font = UIFont.systemFont(ofSize: 40)
            appearance.titleTextAttributes = [.foregroundColor:  #colorLiteral(red: 0.9607843161, green: 0.7058823705, blue: 0.200000003, alpha: 1)]
            appearance.largeTitleTextAttributes = [.foregroundColor:  #colorLiteral(red: 0.9607843161, green: 0.7058823705, blue: 0.200000003, alpha: 1), .font: font]
            
            navigationController?.navigationBar.standardAppearance = appearance
            navigationController?.navigationBar.compactAppearance = appearance
            navigationController?.navigationBar.scrollEdgeAppearance = appearance
        }
        navigationController?.navigationBar.prefersLargeTitles = true
        
        navigationController?.navigationBar.tintColor =  #colorLiteral(red: 0.9607843161, green: 0.7058823705, blue: 0.200000003, alpha: 1)
    }
    
    private func setupViews() {
        view.addSubviews(scrollView, padView)
        padView.addSubviews(clearButton, searchButton)
        
        scrollView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.bottom.equalTo(padView.snp.top)
        }
        
        padView.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.height.equalTo(100)
        }
        
        clearButton.snp.makeConstraints { make in
            make.leading.top.bottom.equalToSuperview().inset(20)
            make.trailing.equalTo(searchButton.snp.leading).offset(-30)
        }
        
        searchButton.snp.makeConstraints { make in
            make.trailing.top.bottom.equalToSuperview().inset(20)
        }
    }

    // MARK: - Keyboard
    deinit {
        removeKeyboardNotifications()
    }
    
    private func registerForKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    private func removeKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    private var isKeyboardShown = false
    
    @objc private func keyboardWillShow(_ notification: Notification) {
        let userInfo = notification.userInfo
        if !isKeyboardShown {
            if let kbFrameSize = (userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {

                let contentInsets = UIEdgeInsets(top: 0, left: 0, bottom: kbFrameSize.height, right: 0)
                scrollView.contentInset = contentInsets
                scrollView.scrollIndicatorInsets = contentInsets
            }
        }
    }

    @objc private func keyboardWillHide() {
        isKeyboardShown = false
        scrollView.contentInset = .zero
        scrollView.scrollIndicatorInsets = .zero
    }
}

// MARK: - @objc
extension AdvancedSearchViewController {
    @objc private func clearButtonTapped() {
        scrollView.setToDefaults()
        onClearButtonTapped?()
    }
    
    @objc private func searchButtonTapped() {
        
        if let year = scrollView.yearTextFieldText, !year.isEmpty {
            if Int(year) == nil {
                self.showError(with: "Incorrect year")
                return
            } else if let year = Int(year) {
                if year < 1900 || year > 2025 {
                    self.showError(with: "Incorrect year")
                    return
                }
            }
        }

        onSearchButtonTapped?(AdvancedSearchModel(rating: scrollView.rating,
                                                  totalVotes: scrollView.totalVotes,
                                                  decade: scrollView.decade,
                                                  year: scrollView.year,
                                                  includeAdult: scrollView.includeAdult,
                                                  primaryLanguage: scrollView.primaryLanguage)
        )
        

    }
    
}
