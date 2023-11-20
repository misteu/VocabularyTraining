//
//  TrainingView.swift
//  VocabularyTrainer
//
//  Created by Mariana Brasil on 04/02/23.
//  Copyright © 2023 mic. All rights reserved.
//

import UIKit

// MARK: - Delegate
protocol TrainingViewDelegate: AnyObject {
    func tappedBarButton()
}

// MARK: - Training View

final class TrainingView: UIView {

    weak var delegate: TrainingViewDelegate?

    // MARK: - Private properties

    private lazy var vocabularies: [String: String]? = [:]
    private lazy var vocabulariesProgresses: [String: Float]? = [:]
    private lazy var isKeyShown: Bool? = false
    private lazy var currentKey: String? = .init()
    private lazy var selectedLanguage: String? = .init()

    private lazy var barButton: UIButton = {
        let button = ModalCloseButton()
        button.addTarget(self,
                         action: #selector(tappedBarButton),
                         for: .touchUpInside)
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
        textField.returnKeyType = .done
        textField.delegate = self
        return textField
    }()

    private lazy var checkButton: UIButton = {
        let button = UIButton(frame: .zero,
                              primaryAction: .init(handler: { [weak self] _ in
            self?.checkButtonAction()
        }))
        button.backgroundColor = .systemGray2
        button.layer.cornerRadius = 3
        button.isEnabled = false
        button.accessibilityTraits = .button
        button.setTitle(Localizable.check.localize(), for: .normal)
        button.titleLabel?.font = .preferredFont(forTextStyle: .headline)
        return button
    }()

	private lazy var checkButtonContainer: UIStackView = UIStackView(arrangedSubviews: [checkButton])

    private lazy var skipButton: UIButton = {
        let button = UIButton(frame: .zero,
                              primaryAction: .init(handler: { [weak self] _ in
            self?.skipButtonAction()
        }))
        button.layer.cornerRadius = 3
        button.layer.borderColor = UIColor(named: "grayButton")?.cgColor
        button.layer.borderWidth = 1
        button.accessibilityTraits = .button
        button.setTitle(Localizable.skip.localize(), for: .normal)
        button.titleLabel?.font = .preferredFont(forTextStyle: .callout)
        button.setTitleColor(UIColor(named: "grayButton"), for: .normal)
        return button
    }()

	let takeLookSwitchControl = UISwitch(frame: .zero)
	private lazy var takeLookContainerView: UIView = {
		let stackView = UIStackView()
		stackView.spacing = 12
		takeLookSwitchControl.addAction(.init(handler: { [weak self] _ in
			self?.takeLookButtonAction(isOn: self?.takeLookSwitchControl.isOn == true)
		}), for: .touchUpInside)
		let titleLabel = UILabel()
		titleLabel.font = .preferredFont(forTextStyle: .caption1)
		titleLabel.text = Localizable.takeLook.localize()
		titleLabel.textAlignment = .right
		stackView.addArrangedSubview(titleLabel)
		stackView.addArrangedSubview(takeLookSwitchControl)
		return stackView
	}()

	/// Contains right / wrong buttons for quickly saving vocabulary.
	private lazy var quickAnswerContainer: UIStackView = {

		let correctButton = UIButton(frame: .zero,
									 primaryAction: .init(handler: { [weak self] _ in
			self?.setQuickAnswer(isCorrect: true)
		}))

		var correctButtonConfig = UIButton.Configuration.plain()
		correctButtonConfig.image = UIImage(systemName: "checkmark")
		correctButtonConfig.imagePadding = 8
		correctButton.configuration = correctButtonConfig
		correctButton.tintColor = .white

		correctButton.layer.cornerRadius = 3
		correctButton.backgroundColor = UIColor(named: "greenButton")?.withAlphaComponent(0.7)
		correctButton.setTitle(Localizable.correctButtonTitle.localize(), for: .normal)
		correctButton.titleLabel?.font = .preferredFont(forTextStyle: .callout)
		correctButton.setTitleColor(.white, for: .normal)

		let wrongButton = UIButton(frame: .zero,
								   primaryAction: .init(handler: { [weak self] _ in
			self?.setQuickAnswer(isCorrect: false)
		}))

		var wrongButtonConfig = UIButton.Configuration.plain()
		wrongButtonConfig.image = UIImage(systemName: "xmark")
		wrongButtonConfig.imagePadding = 8
		wrongButton.configuration = wrongButtonConfig
		wrongButton.tintColor = .white

		wrongButton.layer.cornerRadius = 3
		wrongButton.backgroundColor = UIColor(named: "red")?.withAlphaComponent(0.7)
		wrongButton.setTitle(Localizable.wrongButtonTitle.localize(), for: .normal)
		wrongButton.titleLabel?.font = .preferredFont(forTextStyle: .callout)
		wrongButton.setTitleColor(.white, for: .normal)

		let stackView = UIStackView(arrangedSubviews: [correctButton, wrongButton])
		stackView.spacing = 16
		stackView.distribution = .fillEqually
		return stackView
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
					 checkButtonContainer,
                     skipButton,
					 takeLookContainerView])
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

			checkButtonContainer.topAnchor.constraint(equalTo: answerTextField.bottomAnchor, constant: 16),
			checkButtonContainer.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -24),
			checkButtonContainer.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 24),
			checkButtonContainer.heightAnchor.constraint(equalToConstant: 42),

            skipButton.topAnchor.constraint(equalTo: checkButtonContainer.bottomAnchor, constant: 32),
            skipButton.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 24),
            skipButton.heightAnchor.constraint(equalToConstant: 31),
            skipButton.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width / 2 - 28),

            takeLookContainerView.topAnchor.constraint(equalTo: checkButtonContainer.bottomAnchor, constant: 32),
			takeLookContainerView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -24),
			takeLookContainerView.heightAnchor.constraint(equalToConstant: 31),
			takeLookContainerView.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width / 2 - 28),
        ])
    }

    private func setUpLanguageTrained(selectedLanguage: String) {
        let defaultLabel: String = NSLocalizedString("Training", comment: "Training")
        trainingLanguageLabel.text = "\(defaultLabel) \(selectedLanguage)"

        guard let vocabs = UserDefaults.standard.dictionary(forKey: selectedLanguage) as? [String: String],
              let progresses = UserDefaults.standard.dictionary(forKey: "\(selectedLanguage)Progress") as? [String: Float]? else {
            return
        }

        vocabularies = vocabs
        vocabulariesProgresses = progresses
        self.selectedLanguage = selectedLanguage
    }

    private func setUpTraining() {
        setUpResetTextField()
        setUpDisabledCheckButton()

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
		guard let selectedLanguage = selectedLanguage else { return }
        UserDefaults.standard.set(progresses, forKey: "\(selectedLanguage)Progress")
    }

    private func setUpResetTextField() {
        answerTextField.text = .init()
        answerTextField.borderStyle = .none
        answerTextField.layer.borderWidth = 0
    }

    private func setUpDisabledCheckButton() {
        checkButton.backgroundColor = .systemGray2
        checkButton.isEnabled = false
        checkButton.accessibilityTraits.insert(.notEnabled)
        checkButton.setTitle(Localizable.check.localize(), for: .normal)
    }

    private func setUpEnabledCheckButton() {
        checkButton.backgroundColor = UIColor(named: "greenButton")
        checkButton.isEnabled = true
        checkButton.accessibilityTraits.remove(.notEnabled)
        checkButton.setTitle(Localizable.check.localize(), for: .normal)
    }

    private func takeLookAccessibilityAction() {
        guard let isKey = isKeyShown,
              let key = currentKey,
              let vocabs = vocabularies else { return }

        guard let solution = isKey ? vocabs[key] : key else { return }

        if UIAccessibility.isVoiceOverRunning {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                let answer = "\(Localizable.answer.localize()) \(solution)"
                UIAccessibility.post(notification: .announcement, argument: answer)
            }
        }
    }

    @objc
    private func tappedBarButton() {
        delegate?.tappedBarButton()
    }

    @objc
    private func textFieldEvent() {
        guard let text = answerTextField.text else { return }

        if text.isEmptyOrWhitespace() {
            setUpDisabledCheckButton()
        } else {
            setUpEnabledCheckButton()
        }
        answerTextField.borderStyle = .none
        answerTextField.layer.borderWidth = 0
    }

    @objc
    private func checkButtonAction() {
        guard let usersAnswer = answerTextField.text,
              let isKey = isKeyShown,
              let key = currentKey,
              let vocabs = vocabularies else { return }

        let solution: String? = isKey ? vocabs[key] : key

        if checkButton.titleLabel?.text != Localizable.check.localize() {
            setUpTraining()
            UIAccessibility.focusOn(wordLabel)
            return
        }

        if !usersAnswer.isEmpty,
           usersAnswer.uppercased() == solution?.uppercased() {
            rightAnswer(solution: solution, key: key)
        } else {
            wrongAnswer(key: key)
        }
    }

	private func setQuickAnswer(isCorrect: Bool) {
		guard let isKey = isKeyShown,
			  let key = currentKey,
			  let vocabs = vocabularies else { return }
		let solution: String? = isKey ? vocabs[key] : key
		if isCorrect {
			rightAnswer(solution: solution, key: key)
		} else {
			wrongAnswer(key: key, shouldShake: false)
		}
		resetButtonVisibilities()
		self.setUpTraining()
		wordLabel.shake(xValue: 0, yValue: 12)
	}

	private func resetButtonVisibilities() {
		checkButtonContainer.isHidden = false
		takeLookContainerView.isHidden = false
		takeLookSwitchControl.setOn(false, animated: true)
		takeLookButtonAction(isOn: false)
	}

    @objc
    private func skipButtonAction() {
		skipButton.setTitle(Localizable.skip.localize(), for: .normal)

        softHapticFeedback()
        UIView.animate(withDuration: 0.2, animations: { [weak self] in
            self?.skipButton.backgroundColor = .systemGray4
        }, completion: { _ in
            self.setUpTraining()
        })

        UIView.animate(withDuration: 0.3, animations: { [weak self] in
            self?.skipButton.backgroundColor = nil
        })

        if UIAccessibility.isVoiceOverRunning {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                UIAccessibility.post(notification: .announcement, argument: self.wordLabel.text?.description)
            }
        }
    }

	func takeLookButtonAction(isOn: Bool) {
		softHapticFeedback()
		guard let isKey = isKeyShown,
			  let key = currentKey,
			  let vocabs = vocabularies else { return }
		let solution: String? = isKey ? vocabs[key] : key
		answerTextField.text = isOn ? solution : nil
		updateCheckButtonContainer(isOn: isOn)
	}

	func updateCheckButtonContainer(isOn: Bool) {
		for view in checkButtonContainer.arrangedSubviews {
			view.removeFromSuperview()
		}
		checkButtonContainer.addArrangedSubview(isOn ? quickAnswerContainer : checkButton)
	}

//    @objc
//    private func takeLookButtonAction(_ gestureRecognizer: UILongPressGestureRecognizer) {
//        if gestureRecognizer.state == .began {
//            softHapticFeedback()
//            takeLookButton.backgroundColor = .systemGray2
//            guard let isKey = isKeyShown,
//                  let key = currentKey,
//                  let vocabs = vocabularies else { return }
//            let solution: String? = isKey ? vocabs[key] : key
//            answerTextField.text = solution
//        } else if gestureRecognizer.state == .ended {
//            answerTextField.text = nil
//            takeLookButton.backgroundColor = .darkGray
//        }
//    }

    private func rightAnswer(solution: String?, key: String) {
        guard let solution = solution else { return }
        changeWordsProbability(increase: false, key: key)

        UIView.animate(withDuration: 0.2, animations: { [weak self] in
            self?.answerTextField.layer.borderColor = UIColor(named: "greenButton")?.cgColor
            self?.answerTextField.layer.borderWidth = 1
        }, completion: { _ in
            self.successHapticFeedback()
        })
        checkButton.setTitle(Localizable.nextWord.localize(), for: .normal)
        answerTextField.text = solution
    }

	private func wrongAnswer(key: String, shouldShake: Bool = true) {
        changeWordsProbability(increase: true, key: key)
        UIView.animate(withDuration: 0.2, animations: { [weak self] in
            self?.answerTextField.layer.borderColor = UIColor(named: "red")?.cgColor
            self?.answerTextField.layer.borderWidth = 1
        })
		if shouldShake {
			checkButton.shake()
		}
        errorHapticFeedback()

        if UIAccessibility.isVoiceOverRunning {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                UIAccessibility.post(notification: .announcement, argument: Localizable.wrongAnswer.localize())
            }
        }
    }

    private func successHapticFeedback() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }

    private func errorHapticFeedback() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.error)
    }

    private func softHapticFeedback() {
        let generator = UIImpactFeedbackGenerator(style: .soft)
        generator.impactOccurred(intensity: 0.70)
    }
}

extension TrainingView: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        UIAccessibility.focusOn(answerTextField)
        return true
    }
}
