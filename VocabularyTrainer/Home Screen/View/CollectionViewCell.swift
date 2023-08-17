//
//  CollectionViewCell.swift
//  VocabularyTrainer
//
//  Created by skrr on 29.12.22.
//  Copyright © 2022 mic. All rights reserved.
//

import UIKit

class CollectionViewCell: UICollectionViewCell {

    typealias Dimensions = LanguageCellViewModel.Dimensions
    typealias Colors = LanguageCellViewModel.Colors

    private let titleLabel = UILabel.createLabel(
        font: .preferredFont(forTextStyle: .headline),
        accessibilityTrait: .header,
        fontColor: HomeViewModel.Colors.title
    )

    private let subtitleLabel = UILabel.createLabel(
        font: .preferredFont(forTextStyle: .body),
        fontColor: HomeViewModel.Colors.subtitle
    )

    private let labelContainer: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = Dimensions.labelSpacing
        stackView.distribution = .fill
        return stackView
    }()

    private let background: UIView = {
        let view = UIView()
        view.backgroundColor = Colors.cellBackground
        view.layer.cornerRadius = Dimensions.cornerRadius
        return view
    }()

    private let selectedBackground: UIView = {
        let view = UIView()
        view.backgroundColor = Colors.selectedCellBackground
        view.layer.cornerRadius = Dimensions.cornerRadius
        return view
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpUI()
        setUpConstraints()
    }

    /// Not supported.
    required init?(coder: NSCoder) { nil }

    func configure(with item: LanguageCellViewModel) {
        titleLabel.text = item.languageName
        subtitleLabel.text = item.subtitle
        contentView.accessibilityLabel = "\(item.languageName) \(item.subtitle)"
    }

    private func setUpUI() {
        backgroundView = background
        selectedBackgroundView = selectedBackground
        contentView.backgroundColor = .clear

        labelContainer.addArrangedSubview(titleLabel)
        labelContainer.addArrangedSubview(subtitleLabel)
        contentView.addSubview(labelContainer)
        contentView.isAccessibilityElement = true
        contentView.accessibilityTraits = [.button]
    }

    private func setUpConstraints() {
        NSLayoutConstraint.activate([
            labelContainer.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Dimensions.verticalContainerMargin),
            labelContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Dimensions.horizontalMargin * 2),
            labelContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Dimensions.horizontalMargin),
            labelContainer.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -Dimensions.verticalContainerMargin)
        ])
    }
}
