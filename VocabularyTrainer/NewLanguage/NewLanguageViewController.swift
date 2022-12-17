//
//  NewLanguageViewController.swift
//  VocabularyTrainer
//
//  Created by Mariana Brasil on 16/12/22.
//  Copyright © 2022 mic. All rights reserved.
//

import UIKit

final class NewLanguageViewController: UIViewController {

    // MARK: - Public Properties

    weak var delegate: NewLanguageScreenProtocol?
    var coordinator: MainCoordinator?

    // MARK: - Private Properties

    private lazy var closeButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = UIColor(named: "closeButton")
        button.layer.cornerRadius = 3
        button.translatesAutoresizingMaskIntoConstraints = false
        button.accessibilityTraits = .button
        button.accessibilityLabel = Localizable.close.localize()
        button.addTarget(self,
                         action: #selector(closeButtonAction),
                         for: .touchUpInside)
        return button
    }()

    private lazy var titleLabel: UILabel = .createLabel(font: .systemFont(ofSize: 20, weight: .semibold),
                                                        text: Localizable.addNewLanguage.localize(),
                                                        accessibilityTrait: .header)

    private lazy var languageLabel: UILabel = .createLabel(font: .systemFont(ofSize: 16,
                                                                             weight: .semibold),
                                                           text: Localizable.language.localize(),
                                                           accessibilityTrait: .header)
    private lazy var textField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.placeholder = Localizable.whichLanguage.localize()
        textField.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        textField.backgroundColor = .systemBackground
        textField.leftView = UIView(frame: .init(x: 0,
                                                 y: 0,
                                                 width: 16,
                                                 height: textField.frame.height))
        textField.leftViewMode = .always
        textField.addTarget(self,
                            action: #selector(textFieldDidChange),
                            for: .editingChanged)
        textField.addTarget(self, action: #selector(textFieldAllEvents), for: .allEvents)
        return textField
    }()

    private lazy var feedbackLabel: UILabel = .createLabel(font: .systemFont(ofSize: 14, weight: .light),
                                                           text: Localizable.languageExists.localize(),
                                                           isHidden: true,
                                                           fontColor: "red")

    private lazy var addButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .systemGray2
        button.layer.cornerRadius = 10
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isEnabled = false
        button.accessibilityTraits = .button
        button.setTitle(Localizable.add.localize(), for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
        button.addTarget(self, action: #selector(addButtonAction), for: .touchUpInside)
        return button
    }()

    private var hasDuplicates: Bool {
        let newLanguage = textField.text ?? ""
        guard let savedLanguages = UserDefaults.standard.array(forKey: UserDefaultKeys.languages) as? [String] else {
            return false
        }
        let matches = savedLanguages
            .map { String($0) }
            .filter { $0.lowercased().elementsEqual(newLanguage.lowercased()) }
        return !matches.isEmpty
    }
    
    // MARK: - Init

    init(delegate: NewLanguageScreenProtocol?) {
        self.delegate = delegate
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { nil }

    // MARK: - Override

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUI()
    }

    // MARK: - Private Methods

    private func setUpUI() {
        view.backgroundColor = UIColor(named: "background")
        view.addSubview(closeButton)
        view.addSubview(titleLabel)
        view.addSubview(languageLabel)
        view.addSubview(textField)
        view.addSubview(feedbackLabel)
        view.addSubview(addButton)
        setUpConstraints()
    }

    private func setUpConstraints() {
        NSLayoutConstraint.activate([
            closeButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 20),
            closeButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            closeButton.heightAnchor.constraint(equalToConstant: 6),
            closeButton.widthAnchor.constraint(equalToConstant: 37),

            titleLabel.topAnchor.constraint(equalTo: closeButton.bottomAnchor, constant: 40),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            languageLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 30),
            languageLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            languageLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),

            textField.heightAnchor.constraint(equalToConstant: 46),
            textField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            textField.leadingAnchor.constraint(equalTo: languageLabel.leadingAnchor),
            textField.trailingAnchor.constraint(equalTo: languageLabel.trailingAnchor),
            textField.topAnchor.constraint(equalTo: languageLabel.bottomAnchor, constant: 6),

            feedbackLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            feedbackLabel.topAnchor.constraint(equalTo: textField.bottomAnchor, constant: 8),

            addButton.heightAnchor.constraint(equalToConstant: 48),
            addButton.widthAnchor.constraint(equalToConstant: 168),
            addButton.topAnchor.constraint(equalTo: textField.bottomAnchor, constant: 44),
            addButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
        ])
    }

    @objc
    private func closeButtonAction() {
        dismiss(animated: true)
    }

    @objc
    private func addButtonAction() {
        guard let delegate = self.delegate,
              let newLanguage = textField.text else { return }

        if hasDuplicates {
            languageDuplicate()
            return
        }

        if let savedLanguages = UserDefaults.standard.array(forKey: UserDefaultKeys.languages) as? [String] {
            var languages = savedLanguages
            languages.append(newLanguage)
            UserDefaults.standard.set(languages, forKey: UserDefaultKeys.languages)
        } else {
            UserDefaults.standard.set([newLanguage], forKey: UserDefaultKeys.languages)
          }

        delegate.updateLanguageTable(language: newLanguage)
        dismiss(animated: true)
    }

    @objc
    private func textFieldDidChange() {
        textField.borderStyle = .none
        textField.layer.borderWidth = 0
        feedbackLabel.isHidden = true
    }

    @objc
    private func textFieldAllEvents() {
        guard let text = textField.text else { return }

        if text.isEmptyOrWhitespace() {
            addButton.backgroundColor = .systemGray2
            addButton.isEnabled = false
        } else {
            addButton.backgroundColor = UIColor(named: "greenButton")
            addButton.isEnabled = true
        }
    }

    private func languageDuplicate() {
        textField.borderStyle = .line
        textField.layer.borderColor = UIColor(named: "red")?.cgColor
        textField.layer.borderWidth = 1
        feedbackLabel.isHidden = false
    }
}
