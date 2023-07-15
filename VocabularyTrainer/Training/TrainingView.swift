//
//  TrainingView.swift
//  VocabularyTrainer
//
//  Created by Mariana Brasil on 04/02/23.
//  Copyright © 2023 mic. All rights reserved.
//

import UIKit

// MARK: - Protocol
protocol TrainingViewDelegate: AnyObject {
    func tappedBarButton()
    func setWordLabel()
}

// MARK: - Training View Class

final class TrainingView: UIView {

    // MARK: - Private properties

    weak var delegate: TrainingViewDelegate?

    private lazy var vocabularies: [String: String]? = [:]
    private lazy var vocabulariesProgresses: [String: Float]? = [:]
    private lazy var isKeyShown: Bool? = false
    private lazy var currentKey: String? = .init()

    private lazy var barButton: UIButton = {
        let button: UIButton = .init(frame: .zero,
                                     primaryAction: .init(handler: { [weak self] _ in
            self?.delegate?.tappedBarButton()
        }))
        button.layer.cornerRadius = 3
        button.backgroundColor = .systemGray
        return button
    }()

    private lazy var trainingLanguageLabel: UILabel = {
        let label: UILabel = .init()
        label.font = UIFontMetrics(forTextStyle: .title2)
            .scaledFont(for: .systemFont(ofSize: 20,
                                         weight: .semibold))
        return label
    }()

    private lazy var wordLabel: UILabel = {
        let label: UILabel = .init()
        label.font = UIFontMetrics(forTextStyle: .largeTitle)
            .scaledFont(for: .systemFont(ofSize: 32,
                                         weight: .bold))
        return label
    }()

    private lazy var answerLabel: UILabel = {
        let label: UILabel = .init()
        label.font = UIFontMetrics(forTextStyle: .headline)
            .scaledFont(for: .systemFont(ofSize: 14,
                                         weight: .bold))
        label.text = Localizable.answer.localize()
        return label
    }()

    private lazy var answerTextField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.placeholder = Localizable.translation.localize()
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

    // MARK: - Initializer

    init(selectedLanguage: String) {
        super.init(frame: .zero)
        setUpUI()
        setUpConstraints()
        setUpLanguageTrained(selectedLanguage: selectedLanguage)
        setUpTraining()
    }

    required init?(coder: NSCoder) { nil }

    // MARK: - Private Methods

    private func setUpUI() {
        backgroundColor = UIColor(named: "background")
        addSubviews([barButton,
                     trainingLanguageLabel,
                     wordLabel,
                     answerLabel,
                     answerTextField])
    }

    private func setUpConstraints() {
        NSLayoutConstraint.activate([
            barButton.topAnchor.constraint(equalTo: self.topAnchor, constant: 16),
            barButton.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            barButton.heightAnchor.constraint(equalToConstant: 5),
            barButton.widthAnchor.constraint(equalToConstant: 40),

            trainingLanguageLabel.topAnchor.constraint(equalTo: barButton.bottomAnchor, constant: 36),
            trainingLanguageLabel.centerXAnchor.constraint(equalTo: barButton.centerXAnchor),

            wordLabel.topAnchor.constraint(equalTo: trainingLanguageLabel.bottomAnchor, constant: 32),
            wordLabel.centerXAnchor.constraint(equalTo: barButton.centerXAnchor),

            answerLabel.topAnchor.constraint(equalTo: wordLabel.bottomAnchor, constant: 20),
            answerLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 24),

            answerTextField.topAnchor.constraint(equalTo: answerLabel.bottomAnchor, constant: 4),
            answerTextField.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -24),
            answerTextField.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 24),
            answerTextField.heightAnchor.constraint(equalToConstant: 46)
        ])
    }

    private func setUpLanguageTrained(selectedLanguage: String) {
        let defaultLabel: String = NSLocalizedString("Training", comment: "Training")
        trainingLanguageLabel.text = "\(defaultLabel) \(selectedLanguage)"

        guard let vocabs = UserDefaults.standard.dictionary(forKey: selectedLanguage) as? [String: String] else {
            print("no vocabularies found")
            return
        }

        guard let progresses = UserDefaults.standard.dictionary(forKey: "\(selectedLanguage)Progress") as? [String: Float]? else {
            print("no progresses found")
            return
        }

        vocabularies = vocabs
        vocabulariesProgresses = progresses
    }

    private func setUpTraining() {
        guard let vocabs = vocabularies else { return }
        guard let progresses = vocabulariesProgresses else { return }

        let totalProgress = getTotalProgressFrom(progresses)

        currentKey = pickRandomKeyFrom(vocabs, withProgresses: progresses, totalProgress: totalProgress)

        guard let key = currentKey else { return }

        if (Int.random(in: 0...1) == 0) {
            wordLabel.text = key
            isKeyShown = true
        } else {
            wordLabel.text = vocabs[key]
            isKeyShown = false
        }
    }

    private func getTotalProgressFrom(_ vocabulariesProgresses: [String: Float]) -> Float {
        var result = Float(0)
        for progress in vocabulariesProgresses {
            result += progress.value
        }
        return result
    }

    private func pickRandomKeyFrom(_ vocabularies: [String: String],
                                   withProgresses vocabulariesProgresses: [String: Float],
                                   totalProgress: Float) -> String {
        let randomThreshold = Float.random(in: 0...totalProgress)
        var summedUpProgresses = Float(0)
        var resultKey: String = .init()

        for (key, value) in vocabulariesProgresses {
            summedUpProgresses += value
            if summedUpProgresses > randomThreshold {
                resultKey = key
                break
            }
        }
        return resultKey
    }

    @objc
    private func textFieldEvent() {
        guard let text = answerTextField.text else { return }

        if text.isEmptyOrWhitespace() {

        } else {

        }
        answerTextField.borderStyle = .none
        answerTextField.layer.borderWidth = 0
    }
}
