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

    // MARK: - Initializer

    init(selectedLanguage: String) {
        super.init(frame: .zero)
        setUpUI()
        setUpConstraints()
        setUpLanguageTrained(selectedLanguage: selectedLanguage)
    }

    required init?(coder: NSCoder) { nil }

    // MARK: - Private Methods

    private func setUpUI() {
        addSubviews([barButton,
                    trainingLanguageLabel,
                     wordLabel])
    }

    private func setUpConstraints() {
        NSLayoutConstraint.activate([
            barButton.topAnchor.constraint(equalTo: self.topAnchor, constant: 16),
            barButton.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            barButton.heightAnchor.constraint(equalToConstant: 5),
            barButton.widthAnchor.constraint(equalToConstant: 40),

            trainingLanguageLabel.topAnchor.constraint(equalTo: barButton.bottomAnchor, constant: 36),
            trainingLanguageLabel.centerXAnchor.constraint(equalTo: barButton.centerXAnchor)
        ])
    }

    private func setUpLanguageTrained(selectedLanguage: String) {
        let defaultLabel: String = NSLocalizedString("Training", comment: "Training")
        trainingLanguageLabel.text = "\(defaultLabel) \(selectedLanguage)"
    }

}
