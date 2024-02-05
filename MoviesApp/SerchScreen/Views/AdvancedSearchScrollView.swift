//
//  AdvancedSearchScrollView.swift
//  MoviesApp
//
//  Created by Lubomyr Chorniak on 29.01.2024.
//

import UIKit
import SnapKit

class AdvancedSearchScrollView: UIScrollView {
    
    private enum Constants {
        static let labelFontSize: CGFloat = 32
    }
    
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
    
    private let contentView: UIView = {
        let contentView = UIView()
        contentView.translatesAutoresizingMaskIntoConstraints = false
        return contentView
    }()
    
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
    
    init() {
        super.init(frame: .zero)
        backgroundColor = .systemBackground
        addSubview(contentView)
        contentView.addSubviews(ratingLabel, ratingPickerView, totalVotesLabel,
                                totalVotesSegmentedControl, decadeLabel, decadePickerView,
                                yearLabel, yearTextField, includeAdultLabel,
                                includeAdultSwitch, primaryLanguageLabel,
                                primaryLanguagePickerView)
        
        contentView.snp.makeConstraints { make in
            make.height.equalTo(self.snp.height).priority(1)
        }
        
        contentView.snp.makeConstraints { make in
            make.top.bottom.equalTo(self)
            make.leading.trailing.equalTo(self).inset(10)
            make.width.equalTo(self.snp.width).offset(-20)
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

        
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var yearTextFieldText: String? {
        self.yearTextField.text
    }
    
    public func setPickersDelegate(delegate: UIPickerViewDelegate) {
        ratingPickerView.delegate = delegate
        decadePickerView.delegate = delegate
        primaryLanguagePickerView.delegate = delegate
    }
    
    var rating: String? {
        let rating: String? = ratingsCases[ratingPickerView.selectedRow(inComponent: 0)]
        return rating == "3+" ? nil : rating
    }
    
    var totalVotes: String? {
        let totalVotes: String? = totalVotesCases[totalVotesSegmentedControl.selectedSegmentIndex]
        return totalVotes == "0+" ? nil : totalVotes
    }
    
    var decade: Decade? {
        let decade: Decade? = Decade.allCases[decadePickerView.selectedRow(inComponent: 0)]
        return decade == .anyDecade ? nil : decade
    }
    
    var primaryLanguage: PrimaryLanguage? {
        let primaryLanguage: PrimaryLanguage? = PrimaryLanguage.allCases[primaryLanguagePickerView.selectedRow(inComponent: 0)]
        return primaryLanguage == .anyLanguage ? nil : primaryLanguage
    }
    
    var year: String? {
        let year = yearTextField.text
        return (year == nil || year!.isEmpty) ? nil : year!
    }
    
    var includeAdult: Bool { includeAdultSwitch.isOn }
    
    public func setToDefaults() {
        ratingPickerView.selectRow(0, inComponent: 0, animated: true)
        totalVotesSegmentedControl.selectedSegmentIndex = 0
        decadePickerView.selectRow(0, inComponent: 0, animated: true)
        yearTextField.text = ""
        includeAdultSwitch.isOn = true
        primaryLanguagePickerView.selectRow(0, inComponent: 0, animated: true)
    }
    
}

extension AdvancedSearchScrollView: UIPickerViewDataSource {
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
extension AdvancedSearchScrollView: UIPickerViewDelegate {

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
extension AdvancedSearchScrollView: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        yearTextField.resignFirstResponder()
        return true
    }
}
