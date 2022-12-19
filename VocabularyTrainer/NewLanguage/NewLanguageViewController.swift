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
        let button = ModalCloseButton()
        button.addTarget(self,
                         action: #selector(dismissView),
                         for: .touchUpInside)
        return button
    }()

    private let titleFont = UIFontMetrics(forTextStyle: .title3)
        .scaledFont(for: .systemFont(ofSize: 20, weight: .semibold))

    private lazy var titleLabel: UILabel = .createLabel(font: titleFont,
                                                        text: Localizable.addNewLanguage.localize(),
                                                        accessibilityTrait: .header,
                                                        textAlignment: .center)

    private lazy var languageLabel: UILabel = .createLabel(font: .preferredFont(forTextStyle: .headline),
                                                           text: Localizable.language.localize(),
                                                           accessibilityTrait: .header)
    private lazy var textField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.placeholder = Localizable.whichLanguage.localize()
        textField.font = .preferredFont(forTextStyle: .body)
        textField.backgroundColor = .systemBackground
        textField.leftView = UIView(frame: .init(x: 0,
                                                 y: 0,
                                                 width: 16,
                                                 height: textField.frame.height))
        textField.leftViewMode = .always
        textField.addTarget(self, action: #selector(textFieldEvent), for: .allEvents)
        return textField
    }()

    private let feedbackFont = UIFontMetrics(forTextStyle: .footnote)
        .scaledFont(for: .systemFont(ofSize: 14, weight: .light))

    private lazy var feedbackLabel: UILabel = .createLabel(font: feedbackFont,
                                                           text: Localizable.languageExists.localize(),
                                                           isHidden: true,
                                                           fontColor: "red")

    private lazy var addButton: UIButton = {
        let button = UIButton(frame: .zero,
                              primaryAction: .init(handler: { [weak self] _ in
            self?.addButtonAction()
        }))
        button.backgroundColor = .systemGray2
        button.layer.cornerRadius = 10
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isEnabled = false
        button.accessibilityTraits = .button
        button.setTitle(Localizable.add.localize(), for: .normal)
        button.titleLabel?.font = .preferredFont(forTextStyle: .headline)
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
        view.addSubviews([closeButton,
                          titleLabel,
                          languageLabel,
                          textField,
                          feedbackLabel,
                          addButton])
        setUpConstraints()
    }

    private func setUpConstraints() {
        NSLayoutConstraint.activate([
            closeButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 20),
            closeButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            closeButton.heightAnchor.constraint(equalToConstant: 6),
            closeButton.widthAnchor.constraint(equalToConstant: 37),

            titleLabel.topAnchor.constraint(equalTo: closeButton.bottomAnchor, constant: 30),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),

            languageLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 24),
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
            addButton.topAnchor.constraint(equalTo: feedbackLabel.bottomAnchor, constant: 12),
            addButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
        ])
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

        successHapticFeedback()
        delegate.updateLanguageTable(language: newLanguage)
        dismissView()
    }

    @objc
    private func textFieldEvent() {
        guard let text = textField.text else { return }

        if text.isEmptyOrWhitespace() {
            addButton.backgroundColor = .systemGray2
            addButton.isEnabled = false
        } else {
            addButton.backgroundColor = UIColor(named: "greenButton")
            addButton.isEnabled = true
        }

        textField.borderStyle = .none
        textField.layer.borderWidth = 0
        feedbackLabel.isHidden = true
    }

    private func languageDuplicate() {
        textField.borderStyle = .line
        textField.layer.borderColor = UIColor(named: "red")?.cgColor
        textField.layer.borderWidth = 1
        feedbackLabel.isHidden = false
        addButton.shake()
        errorHapticFeedback()
        focusOnErrorMessage()
    }

    private func focusOnErrorMessage() {
        UIAccessibility.focusOn(feedbackLabel)
    }

    private func successHapticFeedback() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }

    private func errorHapticFeedback() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.error)
    }

    @objc
    private func dismissView() {
        dismiss(animated: true)
    }
}
