//
//  HomeLanguageHeaderView.swift
//  VocabularyTrainer
//
//  Created by Michael Steudter on 19.12.22.
//  Copyright © 2022 mic. All rights reserved.
//

import UIKit

protocol HomeLanguageHeaderViewDelegate: AnyObject {
    func tappedPracticeButton()
    func tappedEditButton()
    func tappedAddLanguageButton()
}

final class HomeLanguageHeaderView: UIView {

    typealias Strings = HomeViewModel.Strings
    typealias Colors = HomeViewModel.Colors

    /// Title with trailing add button.
    private let titleLabel = UILabel()
    /// Button for adding a new language.
    lazy var addLanguageButton: UIButton = {
        let button = UIButton(type: .contactAdd)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.tintColor = .label
        button.addAction(
            .init(handler: { [weak self] _ in
                self?.delegate?.tappedAddLanguageButton()
            }),
            for: .touchUpInside
        )
        return button
    }()
    /// Button for starting practicing mode.
    lazy var practiceButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        let text = NSAttributedString(string: Strings.practiceButtonTitle,
                                      attributes: [.underlineStyle: NSUnderlineStyle.single.rawValue] )
        button.setAttributedTitle(text, for: .normal)
        button.tintColor = Colors.flippyGreen
        button.titleLabel?.font = .preferredFont(forTextStyle: .body)
        button.addAction(.init(handler: { [weak self] _ in self?.delegate?.tappedPracticeButton() }), for: .touchUpInside)
        return button
    }()
    /// Button for editing a language.
    lazy var editButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(Strings.editButtonTitle, for: .normal)
        button.tintColor = .label
        button.addAction(.init(handler: { [weak self] _ in self?.delegate?.tappedEditButton() }), for: .touchUpInside)
        return button
    }()
    /// Stack view horizontally aligning `practiceButton` and `editButton`.
    lazy var buttonStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [practiceButton, editButton])
        stackView.spacing = Layout.defaultMargin
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    weak var delegate: HomeLanguageHeaderViewDelegate?

    // MARK: - Initializer

    init() {
        super.init(frame: .zero)
        setupUI()
        setupConstraints()
    }

    required init?(coder: NSCoder) { nil }

    // MARK: - Setup

    private func setupUI() {
        titleLabel.font = UIFontMetrics(forTextStyle: .title2).scaledFont(for: .systemFont(ofSize: 20, weight: .semibold))
        titleLabel.text = Strings.headerTitle
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        translatesAutoresizingMaskIntoConstraints = false
        addSubviews([titleLabel, addLanguageButton, buttonStackView])
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            titleLabel.topAnchor.constraint(equalTo: topAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor),

            addLanguageButton.leadingAnchor.constraint(equalTo: titleLabel.trailingAnchor, constant: 8),
            addLanguageButton.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            addLanguageButton.heightAnchor.constraint(equalToConstant: 44),
            addLanguageButton.widthAnchor.constraint(equalToConstant: 44),

            buttonStackView.leadingAnchor.constraint(greaterThanOrEqualTo: addLanguageButton.trailingAnchor, constant: Layout.defaultMargin),
            buttonStackView.topAnchor.constraint(greaterThanOrEqualTo: topAnchor),
            buttonStackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            buttonStackView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
}
