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
    private lazy var selectedLanguage: String? = .init()

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
        textField.autocapitalizationType = .none
        textField.autocorrectionType = .no
        return textField
    }()

    private lazy var checkButton: UIButton = {
        let button = UIButton(frame: .zero,
                              primaryAction: .init(handler: { [weak self] _ in
            self?.checkButtonAction()
        }))
        button.backgroundColor = .systemGray2
        button.layer.cornerRadius = 3
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isEnabled = false
        button.accessibilityTraits = .button
        button.setTitle(Localizable.check.localize(), for: .normal)
        button.titleLabel?.font = .preferredFont(forTextStyle: .headline)
        return button
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
                     answerTextField,
                     checkButton])
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
            answerTextField.heightAnchor.constraint(equalToConstant: 46),

            checkButton.topAnchor.constraint(equalTo: answerTextField.bottomAnchor, constant: 16),
            checkButton.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -24),
            checkButton.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 24),
            checkButton.heightAnchor.constraint(equalToConstant: 42)
        ])
    }

    private func setUpLanguageTrained(selectedLanguage: String) {
        let defaultLabel: String = NSLocalizedString("Training", comment: "Training")
        trainingLanguageLabel.text = "\(defaultLabel) \(selectedLanguage)"

        guard let vocabs = UserDefaults.standard.dictionary(forKey: selectedLanguage) as? [String: String],
              let progresses = UserDefaults.standard.dictionary(forKey: "\(selectedLanguage)Progress") as? [String: Float]? else {
            // empty case
            return
        }


        vocabularies = vocabs
        vocabulariesProgresses = progresses
        self.selectedLanguage = selectedLanguage
    }

    private func setUpTraining() {
        guard let vocabs = vocabularies,
              let progresses = vocabulariesProgresses else { return }

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

    private func changeWordsProbability(increase: Bool, key: String) {
        guard var progresses = vocabulariesProgresses,
              let key = currentKey,
              let progress = progresses[key] else { return }

        if increase {
            progresses[key] = progress+Float(10.0)
        } else if (progress-Float(3.0) > 0) {
            progresses[key] = progress-Float(3.0)
        } else {
            progresses[key] = 1.0
        }
        UserDefaults.standard.set(progresses, forKey: "\(selectedLanguage)Progress")
    }

    @objc
    private func textFieldEvent() {
        guard let text = answerTextField.text else { return }

        if text.isEmptyOrWhitespace() {
            checkButton.backgroundColor = .systemGray2
            checkButton.isEnabled = false
        } else {
            checkButton.backgroundColor = UIColor(named: "greenButton")
            checkButton.isEnabled = true
        }
        answerTextField.borderStyle = .none
        answerTextField.layer.borderWidth = 0
    }

    @objc func checkButtonAction() {
        guard let usersAnswer = answerTextField.text,
              let isKey = isKeyShown,
              let key = currentKey,
              let vocabs = vocabularies else {  return }

        let solution: String? = isKey ? vocabs[key] : key

        if !usersAnswer.isEmpty,
           usersAnswer.uppercased() == solution?.uppercased() {
            rightAnswer(solution: solution, key: key)
        } else {
            wrongAnswer(key: key)
        }
    }

    private func rightAnswer(solution: String?, key: String) {
        guard let solution = solution else { return }
        changeWordsProbability(increase: false, key: key)

        UIView.animate(withDuration: 0.2, animations: { [weak self] in
            self?.answerTextField.layer.borderColor = UIColor(named: "greenButton")?.cgColor
            self?.answerTextField.layer.borderWidth = 1
            //self.checkInputButton.alpha = 0.0
            //self.takeALookButton.alpha = 0.0
        }, completion: { _ in
            self.successHapticFeedback()
        })
        answerTextField.text = solution
        checkButton.setTitle(Localizable.nextWord.localize(), for: .normal)
        debugPrint("AAAAAAA")
    }

    private func wrongAnswer(key: String) {
        changeWordsProbability(increase: true, key: key)
        UIView.animate(withDuration: 0.2, animations: { [weak self] in
            self?.answerTextField.layer.borderColor = UIColor(named: "red")?.cgColor
            self?.answerTextField.layer.borderWidth = 1
        })
        checkButton.shake()
        errorHapticFeedback()
    }

    private func successHapticFeedback() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }

    private func errorHapticFeedback() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.error)
    }
}
