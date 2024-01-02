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
        
        guard let ratingRow = ratingsCases.firstIndex(of: searchParameters.rating ?? "3+" ) else { return }
        ratingPickerView.selectRow(ratingRow, inComponent: 0, animated: false)
        
        switch searchParameters.totalVotes {
        case "1000+":
            totalVotesSegmentedControl.selectedSegmentIndex = 1
        case "10 000+":
            totalVotesSegmentedControl.selectedSegmentIndex = 2
        case "100 000+":
            totalVotesSegmentedControl.selectedSegmentIndex = 3
        case "1 000 000+":
            totalVotesSegmentedControl.selectedSegmentIndex = 4
        default:
            totalVotesSegmentedControl.selectedSegmentIndex = 0
        }
        
        guard let decadeRow = Decade.allCases.firstIndex(of: searchParameters.decade ?? .anyDecade) else { return }
        decadePickerView.selectRow(decadeRow, inComponent: 0, animated: false)
        
        yearTextField.text = searchParameters.year
        
        includeAdultSwitch.isOn = searchParameters.includeAdult
        
        guard let primaryLanguageRow = PrimaryLanguage.allCases.firstIndex(of: searchParameters.primaryLanguage ?? .anyLanguage) else { return }
        primaryLanguagePickerView.selectRow(primaryLanguageRow, inComponent: 0, animated: false)
    }

    // MARK: - ScrollView
    lazy private var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.backgroundColor = .systemBackground
        return scrollView
    }()
    
    private let contentView: UIView = {
        let contentView = UIView()
        contentView.translatesAutoresizingMaskIntoConstraints = false
        return contentView
    }()
    
    // MARK: - Rating
    private let ratingLabel: UILabel = {
        let label = UILabel()
        label.text = "Rating"
        label.font = .systemFont(ofSize: Constants.labelFontSize, weight: .semibold)
        label.textColor = #colorLiteral(red: 0.9607843161, green: 0.7058823705, blue: 0.200000003, alpha: 1)
        label.numberOfLines = 1
        label.setContentCompressionResistancePriority(.required, for: .horizontal)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let ratingsCases = ["3+", "4+", "5+", "6+", "7+", "8+", "9+"]
    
    lazy private var ratingPickerView: UIPickerView = {
        let picker = UIPickerView()
        picker.delegate = self
        picker.dataSource = self
        picker.translatesAutoresizingMaskIntoConstraints = false
        return picker
    }()
    
    // MARK: - Total votes
    private let totalVotesLabel: UILabel = {
        let label = UILabel()
        label.text = "Total Votes"
        label.font = .systemFont(ofSize: Constants.labelFontSize, weight: .semibold)
        label.textColor = #colorLiteral(red: 0.9607843161, green: 0.7058823705, blue: 0.200000003, alpha: 1)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let totalVotesCases = ["0+", "1000+", "10 000+", "100 000+", "1 000 000+"]
    
    lazy private var totalVotesSegmentedControl: UISegmentedControl = {
        let segmentedControl = UISegmentedControl(items: totalVotesCases)
        segmentedControl.setWidth(40, forSegmentAt: 0)
        segmentedControl.selectedSegmentIndex = 0
        return segmentedControl
    }()
    
    // MARK: - Decade
    private let decadeLabel: UILabel = {
        let label = UILabel()
        label.text = "Decade"
        label.font = .systemFont(ofSize: Constants.labelFontSize, weight: .semibold)
        label.textColor = #colorLiteral(red: 0.9607843161, green: 0.7058823705, blue: 0.200000003, alpha: 1)
        label.setContentCompressionResistancePriority(.required, for: .horizontal)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy private var decadePickerView: UIPickerView = {
        let picker = UIPickerView()
        picker.delegate = self
        picker.dataSource = self
        picker.translatesAutoresizingMaskIntoConstraints = false
        return picker
    }()

    // MARK: - Year
    private let yearLabel: UILabel = {
        let label = UILabel()
        label.text = "Year"
        label.font = .systemFont(ofSize: Constants.labelFontSize, weight: .semibold)
        label.textColor = #colorLiteral(red: 0.9607843161, green: 0.7058823705, blue: 0.200000003, alpha: 1)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy private var yearTextField: CustomTextField = {
        let textField = CustomTextField(placeholder: "enter year")
        textField.delegate = self
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    // MARK: - Include adult
    private let includeAdultLabel: UILabel = {
        let label = UILabel()
        label.text = "Include Adult"
        label.font = .systemFont(ofSize: Constants.labelFontSize, weight: .semibold)
        label.textColor = #colorLiteral(red: 0.9607843161, green: 0.7058823705, blue: 0.200000003, alpha: 1)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let includeAdultSwitch: UISwitch = {
        let `switch` = UISwitch()
        `switch`.isOn = true
        `switch`.translatesAutoresizingMaskIntoConstraints = false
        return `switch`
    }()
    
    //MARK: - Primary Language
    private let primaryLanguageLabel: UILabel = {
        let label = UILabel()
        label.text = "Primary Language"
        label.font = .systemFont(ofSize: Constants.labelFontSize, weight: .semibold)
        label.textColor = #colorLiteral(red: 0.9607843161, green: 0.7058823705, blue: 0.200000003, alpha: 1)
        label.numberOfLines = 2
        label.setContentCompressionResistancePriority(.required, for: .horizontal)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
        
    lazy private var primaryLanguagePickerView: UIPickerView = {
        let picker = UIPickerView()
        picker.delegate = self
        picker.dataSource = self
        picker.translatesAutoresizingMaskIntoConstraints = false
        return picker
    }()
    
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
    
    // MARK: - Constants
    private enum Constants {
        static let labelFontSize: CGFloat = 32
    }
    
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
        scrollView.addSubview(contentView)
        contentView.addSubviews(ratingLabel, ratingPickerView, totalVotesLabel,
                                totalVotesSegmentedControl, decadeLabel, decadePickerView,
                                yearLabel, yearTextField, includeAdultLabel,
                                includeAdultSwitch, primaryLanguageLabel,
                                primaryLanguagePickerView)
        
        contentView.snp.makeConstraints { make in
            make.height.equalTo(scrollView.snp.height).priority(1)
        }
        
        scrollView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.bottom.equalTo(padView.snp.top)
        }
        
        contentView.snp.makeConstraints { make in
            make.top.bottom.equalTo(scrollView)
            make.leading.trailing.equalTo(scrollView).inset(10)
            make.width.equalTo(scrollView.snp.width).offset(-20)
        }
        
        // Rating
        ratingLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(10)
            make.trailing.equalTo(ratingPickerView.snp.leading)
            make.centerY.equalTo(ratingPickerView)
        }
        
        ratingPickerView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.trailing.equalToSuperview()
            make.height.equalTo(130)
        }
        
        // Total Votes
        totalVotesLabel.snp.makeConstraints { make in
            make.top.equalTo(ratingPickerView.snp.bottom).offset(10)
            make.leading.equalToSuperview().inset(10)
        }
        
        totalVotesSegmentedControl.snp.makeConstraints { make in
            make.top.equalTo(totalVotesLabel.snp.bottom).offset(15)
            make.leading.trailing.equalToSuperview().inset(10)
        }
        
        // Decade
        decadeLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(10)
            make.trailing.equalTo(decadePickerView.snp.leading)
            make.centerY.equalTo(decadePickerView)
        }
        
        decadePickerView.snp.makeConstraints { make in
            make.top.equalTo(totalVotesSegmentedControl.snp.bottom).offset(15)
            make.trailing.equalToSuperview()
            make.height.equalTo(130)
        }
        
        // Year
        yearLabel.snp.makeConstraints { make in
            make.top.equalTo(decadePickerView.snp.bottom).offset(10)
            make.leading.equalToSuperview().inset(10)
        }
        
        yearTextField.snp.makeConstraints { make in
            make.top.equalTo(yearLabel.snp.bottom).offset(15)
            make.leading.trailing.equalToSuperview().inset(10)
            make.height.equalTo(44)
        }
        
        // Include Adult
        includeAdultLabel.snp.makeConstraints { make in
            make.top.equalTo(yearTextField.snp.bottom).offset(30)
            make.leading.equalToSuperview().inset(10)
            make.trailing.lessThanOrEqualTo(includeAdultSwitch).offset(-10)
        }
        
        includeAdultSwitch.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(10)
            make.centerY.equalTo(includeAdultLabel)
        }
        
        // Primary Language
        primaryLanguageLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(10)
            make.trailing.equalTo(primaryLanguagePickerView.snp.leading)
            make.centerY.equalTo(primaryLanguagePickerView)
        }
        
        primaryLanguagePickerView.snp.makeConstraints { make in
            make.top.equalTo(includeAdultSwitch.snp.bottom).offset(15)
            make.trailing.equalToSuperview()
            make.height.equalTo(130)
            make.bottom.equalToSuperview().inset(15)
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
        ratingPickerView.selectRow(0, inComponent: 0, animated: true)
        totalVotesSegmentedControl.selectedSegmentIndex = 0
        decadePickerView.selectRow(0, inComponent: 0, animated: true)
        yearTextField.text = ""
        includeAdultSwitch.isOn = true
        primaryLanguagePickerView.selectRow(0, inComponent: 0, animated: true)
        
        onClearButtonTapped?()
    }
    
    @objc private func searchButtonTapped() {
        if let year = yearTextField.text, !year.isEmpty {
            if Int(year) == nil {
                UIAlertController.showError(with: "Incorrect year", on: self)
                return
            } else if let year = Int(year) {
                if year < 1900 || year > 2025 {
                    UIAlertController.showError(with: "Incorrect year", on: self)
                    return
                }
            }
        }
        
        var rating: String? = ratingsCases[ratingPickerView.selectedRow(inComponent: 0)]
        rating = rating == "3+" ? nil : rating
        
        var totalVotes: String? = totalVotesCases[totalVotesSegmentedControl.selectedSegmentIndex]
        totalVotes = totalVotes == "0+" ? nil : totalVotes
        
        var decade: Decade? = Decade.allCases[decadePickerView.selectedRow(inComponent: 0)]
        decade = decade == .anyDecade ? nil : decade
        
        var primaryLanguage: PrimaryLanguage? = PrimaryLanguage.allCases[primaryLanguagePickerView.selectedRow(inComponent: 0)]
        primaryLanguage = primaryLanguage == .anyLanguage ? nil : primaryLanguage

        var year = yearTextField.text
        year = (year == nil || year!.isEmpty) ? nil : year!

        onSearchButtonTapped?(AdvancedSearchModel(rating: rating,
                                                  totalVotes: totalVotes,
                                                  decade: decade,
                                                  year: year,
                                                  includeAdult: includeAdultSwitch.isOn,
                                                  primaryLanguage: primaryLanguage)
        )
        

    }
    
}

// MARK: - UIPickerViewDataSource
extension AdvancedSearchViewController: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView === ratingPickerView {
            return ratingsCases.count
        } else if pickerView === decadePickerView {
            return Decade.allCases.count
        } else if pickerView === primaryLanguagePickerView {
            return PrimaryLanguage.allCases.count
        }
        
        return 0
    }
    
}

// MARK: - UIPickerViewDelegate
extension AdvancedSearchViewController: UIPickerViewDelegate {

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView === ratingPickerView {
            return ratingsCases[row]
        } else if pickerView === decadePickerView {
            return Decade.allCases[row].rawValue
        } else if pickerView === primaryLanguagePickerView {
            return PrimaryLanguage.allCases[row].rawValue
        }
        
        return nil
    }
}

// MARK: - UITextFieldDelegate
extension AdvancedSearchViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        yearTextField.resignFirstResponder()
        return true
    }
}
