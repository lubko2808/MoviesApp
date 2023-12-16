//
//  MovieListsSectionTitle.swift
//  MoviesApp
//
//  Created by Любомир  Чорняк on 16.12.2023.
//

import UIKit
import SnapKit

protocol MovieListsSectionTitleProtocol: AnyObject {
    func didTapAddListButton(_ listName: String) -> String?
    func keyboardIsInvoked()
}

class MovieListsSectionTitle: UICollectionReusableView {
    
    var shouldAddNewList: ((_ listName: String) -> (String?))?
    
    weak var delegate: MovieListsSectionTitleProtocol?
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.adjustsFontForContentSizeCategory = true
        label.font = UIFont.boldSystemFont(ofSize: 30)
        label.text = "Lists"
        return label
    }()
    
    let addButton: UIButton = {
        let button = UIButton()
        button.setTitle("Add List", for: .normal)
        button.setTitleColor(UIColor.white, for: .normal)
        button.backgroundColor = .purple
        button.layer.cornerRadius = 15
        button.layer.borderColor = UIColor.black.cgColor
        button.layer.borderWidth = 2
        button.clipsToBounds = true
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    let textField: CustomTextField = {
        let textField = CustomTextField(placeholder: "Enter the new list")
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private var isErrorMessageDisplayed = false
    
    private let errorMessageLabel: UILabel = {
        let label = UILabel()
        label.text = "some text"
        label.textColor = .red
        label.font = UIFont.preferredFont(forTextStyle: .body)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    static let reuseIdentifier = "title-supplementary-reuse-identifier"

    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    var textFieldBottomConstraint: Constraint?

}

extension MovieListsSectionTitle {
    
    
    func configure() {
        addSubview(titleLabel)
        addSubview(addButton)
        addSubview(textField)
        textField.delegate = self
        addButton.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        
        titleLabel.snp.makeConstraints { make in
             make.leading.top.bottom.equalToSuperview().inset(5)
        }

        textField.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(5)
            make.top.equalToSuperview().inset(15)
            textFieldBottomConstraint = make.bottom.equalTo(addButton.snp.top).offset(-10).constraint
            make.height.equalTo(30)
        }

        addButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(5)
            make.bottom.equalToSuperview().inset(15)
            make.width.equalTo(100)
            make.height.equalTo(30)
        }
    }
    
    @objc func buttonTapped(_ sender: Any) {
        addListIfNeeded()
    }
 
    private func addListIfNeeded() {
        if let errorMessage = delegate?.didTapAddListButton(self.textField.text ?? "") {
            if isErrorMessageDisplayed {
                errorMessageLabel.text = errorMessage
            } else {
                errorMessageLabel.text = errorMessage
                addErrorMessageOnScreen()
                isErrorMessageDisplayed = true
            }
        } else {
            if isErrorMessageDisplayed { removeErrorMessageFromScreen() }
            self.textField.resignFirstResponder()
        }
        
        self.textField.text = ""
    }
    

    
    private func addErrorMessageOnScreen() {
        addSubview(errorMessageLabel)
    
        textField.snp.updateConstraints { make in
            make.top.equalToSuperview().inset(5)
        }
        
        textFieldBottomConstraint?.deactivate()
        textField.snp.makeConstraints { make in
            textFieldBottomConstraint = make.bottom.equalTo(errorMessageLabel.snp.top).offset(-5).constraint
        }
        
        addButton.snp.updateConstraints { make in
            make.bottom.equalToSuperview().inset(5)
        }
        
        errorMessageLabel.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(5)
            make.height.equalTo(20)
            make.top.equalTo(textField.snp.bottom).offset(5)
            make.bottom.equalTo(addButton.snp.top).offset(-5)
        }
    }
    
    private func removeErrorMessageFromScreen() {
        errorMessageLabel.snp.removeConstraints()
        
        textFieldBottomConstraint?.deactivate()
        textField.snp.makeConstraints { make in
            textFieldBottomConstraint = make.bottom.equalTo(addButton.snp.top).offset(-10).constraint
        }

        textField.snp.updateConstraints { make in
            make.top.equalToSuperview().inset(15)
        }
        
        addButton.snp.updateConstraints { make in
            make.bottom.equalToSuperview().inset(15)
        }
        
        errorMessageLabel.removeFromSuperview()
        isErrorMessageDisplayed = false
    }
    
    
    
}

// MARK: - UITextFieldDelegate
extension MovieListsSectionTitle: UITextFieldDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        addListIfNeeded()
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        delegate?.keyboardIsInvoked()
    }
    
}
