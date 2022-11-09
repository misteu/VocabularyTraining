//
//  AddNewWordViewController.swift
//  VocabularyTrainer
//
//  Created by Mariana Brasil on 24/10/22.
//  Copyright © 2022 mic. All rights reserved.
//

import UIKit

final class AddNewWordViewController: UIViewController {
    
    // MARK: - Private Properties
    weak var delegate: AddWordDelegate?
    var coordinator: MainCoordinator?
//
//    private lazy var backButton: UIButton = {
//        let button = UIButton()
//        button.setTitle(NSLocalizedString("< Back", comment: "< Back"), for: .normal)
//        button.backgroundColor = BackgroundColor.hansaYellow
//        button.layer.cornerRadius = 5.0
//        button.contentEdgeInsets = .init(top: 5, left: 10, bottom: 5, right: 10)
//        button.setTitleColor(BackgroundColor.japaneseIndigo, for: .normal)
//        button.addTarget(self, action: #selector(didTapBackButton), for: .touchUpInside)
//        button.translatesAutoresizingMaskIntoConstraints = false
//        return button
//    }()
    
    private lazy var addNewWordLabel: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("Add new word", comment: "Add new word")
        label.font = UIFont.systemFont(ofSize: 30)
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var newWordTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = NSLocalizedString("New word", comment: "new word")
        textField.font = UIFont.systemFont(ofSize: 32)
        textField.backgroundColor = .white
        textField.layer.cornerRadius = 5.0
        textField.layer.sublayerTransform = CATransform3DMakeTranslation(8, 0, 0)
        textField.autocapitalizationType = .none
        textField.autocorrectionType = .no
        textField.addTarget(self, action: #selector(textFieldChanged), for: .editingChanged)
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private lazy var translationTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = NSLocalizedString("translation", comment: "translation")
        textField.font = UIFont.systemFont(ofSize: 32)
        textField.backgroundColor = .white
        textField.layer.cornerRadius = 5.0
        textField.layer.sublayerTransform = CATransform3DMakeTranslation(8, 0, 0)
        textField.autocapitalizationType = .none
        textField.autocorrectionType = .no
        textField.addTarget(self, action: #selector(textFieldChanged), for: .editingChanged)
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private lazy var addButton: UIButton = {
        let button = UIButton()
        button.setTitle(NSLocalizedString("Add", comment: "Add"), for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 32)
        button.layer.cornerRadius = 5.0
        button.contentEdgeInsets = .init(top: 0, left: 10, bottom: 0, right: 10)
        button.setTitleColor(BackgroundColor.japaneseIndigo, for: .normal)
        button.addTarget(self, action: #selector(addNewWordTapped), for: .touchUpInside)
        button.backgroundColor = UIColor(red: 207/255, green: 207/255, blue: 205/255, alpha: 0.4)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private var selectedLanguage: String?
    private var vocabularies = [String: String]()
    private var vocabulariesSuccessRates = [String: Float]()
    private var vocabulariesAddDates = [String: Date]()
    private var newWordHasText = false
    private var translationHasText = false
    private var completed: (() -> Void)?
    
    // MARK: - Initializer
    
    init(selectedLanguage: String?) {
        super.init(nibName: nil, bundle: nil)
        self.selectedLanguage = selectedLanguage
        hideKeyboardWhenTappedAround()
        setUpUI()
        setUpConstraints()
        setUpInterfaceStyleUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Private Methods
    
    private func setUpUI() {
        setGradientBackground(view: view)
//        view.addSubview(backButton)
        view.addSubview(addNewWordLabel)
        view.addSubview(newWordTextField)
        view.addSubview(translationTextField)
        view.addSubview(addButton)
    }
    
    private func setUpConstraints() {
//        backButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 16).isActive = true
//        backButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16).isActive = true
//
        addNewWordLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        addNewWordLabel.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor).isActive = true
        
        newWordTextField.topAnchor.constraint(equalTo: addNewWordLabel.bottomAnchor, constant: 16).isActive = true
        newWordTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24).isActive = true
        newWordTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24).isActive = true
        
        translationTextField.topAnchor.constraint(equalTo: newWordTextField.bottomAnchor, constant: 16).isActive = true
        translationTextField.leadingAnchor.constraint(equalTo: newWordTextField.leadingAnchor).isActive = true
        translationTextField.trailingAnchor.constraint(equalTo: newWordTextField.trailingAnchor).isActive = true
        
        addButton.topAnchor.constraint(equalTo: translationTextField.bottomAnchor, constant: 24).isActive = true
        addButton.leadingAnchor.constraint(equalTo: translationTextField.leadingAnchor).isActive = true
        addButton.trailingAnchor.constraint(equalTo: translationTextField.trailingAnchor).isActive = true
    }
    
    private func setUpInterfaceStyleUI() {
        switch traitCollection.userInterfaceStyle {
        
        case .light, .unspecified:
            addNewWordLabel.textColor = .black
            
            newWordTextField.backgroundColor = .white
            newWordTextField.textColor = .black
            
            translationTextField.backgroundColor = .white
            translationTextField.textColor = .black
        
        case .dark:
            addNewWordLabel.textColor = .white
            
            newWordTextField.backgroundColor = .black
            newWordTextField.textColor = .white
            
            translationTextField.backgroundColor = .black
            translationTextField.textColor = .white
        
        @unknown default:
            // Crash if new unhandled cases added
            fatalError()
        }
    }
    
    private func addButtonIsEnabled(_ isEnabled: Bool) {
        if isEnabled {
            UIView.animate(withDuration: 0.3) { [weak self] in
                self?.addButton.backgroundColor = BackgroundColor.mediumSpringBud
            }
            addButton.isEnabled = isEnabled
        } else {
            UIView.animate(withDuration: 0.3) { [weak self] in
                self?.addButton.backgroundColor = UIColor(red: 207/255, green: 207/255, blue: 205/255, alpha: 0.4)
            }
            addButton.isEnabled = isEnabled
        }
    }
        
    private func resetConfigs() {
        newWordTextField.text = ""
        translationTextField.text = ""
        newWordHasText = false
        translationHasText = false
        addButtonIsEnabled(false)
    }
    
    @objc private func didTapBackButton() {
        completed?()
        dismiss(animated: true)
    }
    
    @objc private func addNewWordTapped() {
        guard let language = selectedLanguage,
              let word = newWordTextField.text,
              let translatedWord = translationTextField.text else { return }
        
        let languageVocabProgressKey = "\(language)Progress"
        let languageVocabDateAddedKey = "\(language)DateAdded"
        
        if let vocabs = UserDefaults.standard.dictionary(forKey: language) as? [String: String] {
            vocabularies = vocabs
        }
        
        if let vocabsSuccess = UserDefaults.standard.dictionary(forKey: languageVocabProgressKey) as? [String: Float] {
            vocabulariesSuccessRates = vocabsSuccess
        }
        
        if let vocabsDates = UserDefaults.standard.dictionary(forKey: languageVocabDateAddedKey) as? [String: Date] {
            vocabulariesAddDates = vocabsDates
        }
        
        vocabularies[word] = translatedWord
        vocabulariesSuccessRates[word] = 100
        vocabulariesAddDates[word] = Date()
        
        UserDefaults.standard.set(vocabularies, forKey: language)
        UserDefaults.standard.set(vocabulariesSuccessRates, forKey: languageVocabProgressKey)
        UserDefaults.standard.set(vocabulariesAddDates, forKey: languageVocabDateAddedKey)
        
        resetConfigs()
        self.delegate?.wordAdded()
        showToast(message: NSLocalizedString("New word added", comment: "New word added"), yCoord: 340.0)
    }
    
    @objc private func textFieldChanged(_ sender: UITextField) {
        
        var hasText = false
        if let senderText = sender.text, !senderText.isEmpty {
            hasText = true
        }
                
        if sender === newWordTextField {
            newWordHasText = hasText
        }
        
        if sender === translationTextField {
            translationHasText = hasText
        }
        
        addButtonIsEnabled(newWordHasText && translationHasText)
    }
}
