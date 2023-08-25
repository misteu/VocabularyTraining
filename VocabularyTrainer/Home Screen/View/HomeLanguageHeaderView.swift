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
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFontMetrics(forTextStyle: .title2).scaledFont(for: .systemFont(ofSize: 20, weight: .semibold))
        label.text = Strings.headerTitle
        label.accessibilityTraits = .header
        return label
    }()

    /// Button for adding a new language.
    lazy var addLanguageButton: UIButton = {
        let button = UIButton(type: .contactAdd)
        button.accessibilityLabel = Localizable.addNewLanguage.localize()
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
        let text = NSAttributedString(string: Strings.practiceButtonTitle,
                                      attributes: [.underlineStyle: NSUnderlineStyle.single.rawValue] )
        button.setAttributedTitle(text, for: .normal)
        button.tintColor = Colors.flippyGreen
        button.titleLabel?.font = .preferredFont(forTextStyle: .body)
        button.addAction(.init(handler: { [weak self] _ in self?.delegate?.tappedPracticeButton() }), for: .touchUpInside)
        button.isHidden = true
        return button
    }()
    /// Button for editing a language.
    lazy var editButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(Strings.editButtonTitle, for: .normal)
        button.tintColor = .label
        button.addAction(.init(handler: { [weak self] _ in self?.delegate?.tappedEditButton() }), for: .touchUpInside)
        button.isHidden = true
        return button
    }()
    /// Stack view horizontally aligning `practiceButton` and `editButton`.
    lazy var buttonStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [practiceButton, editButton])
        stackView.spacing = Layout.defaultMargin
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

    func shouldHideHeaderButtons(_ isHidden: Bool) {
        practiceButton.isHidden = isHidden
        editButton.isHidden = isHidden
    }

    // MARK: - Setup

    private func setupUI() {
        addSubviews([titleLabel, addLanguageButton, buttonStackView])
        accessibilityElements = [titleLabel, addLanguageButton, buttonStackView]
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            titleLabel.topAnchor.constraint(equalTo: topAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor),

            addLanguageButton.leadingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            addLanguageButton.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            addLanguageButton.heightAnchor.constraint(equalToConstant: 44),
            addLanguageButton.widthAnchor.constraint(equalToConstant: 44),

            buttonStackView.leadingAnchor.constraint(greaterThanOrEqualTo: addLanguageButton.trailingAnchor, constant: Layout.defaultMargin),
            buttonStackView.topAnchor.constraint(greaterThanOrEqualTo: titleLabel.topAnchor, constant: -5),
            buttonStackView.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
    }
}
