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

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = HomeViewModel.Colors.title
        label.font = .preferredFont(forTextStyle: .headline)
        label.numberOfLines = 0
        return label
    }()

    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = HomeViewModel.Colors.subtitle
        label.font = .preferredFont(forTextStyle: .body)
        label.numberOfLines = 0
        return label
    }()

    private let labelContainer: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = Dimensions.labelSpacing
        stackView.distribution = .fill
        return stackView
    }()

    /// Image view showing the language's icon / image / emoji.
    private let imageView: UIImageView = {
        let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.contentMode = .scaleAspectFit
        view.image = UIImage(systemName: "hare")
        view.clipsToBounds = true
        return view
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
        setUp()
    }

    /// Not supported.
    required init?(coder: NSCoder) { nil }

    func configure(with item: LanguageCellViewModel) {
        titleLabel.text = item.languageName
        subtitleLabel.text = item.subtitle
    }

    private func setUp() {

        backgroundView = background
        selectedBackgroundView = selectedBackground
        contentView.backgroundColor = .clear

        labelContainer.addArrangedSubview(titleLabel)
        labelContainer.addArrangedSubview(subtitleLabel)
        contentView.addSubview(labelContainer)
        contentView.addSubview(imageView)

        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Dimensions.horizontalMargin),
            imageView.trailingAnchor.constraint(equalTo: labelContainer.leadingAnchor, constant: -Dimensions.horizontalMargin),
            imageView.centerYAnchor.constraint(equalTo: labelContainer.centerYAnchor),
            imageView.heightAnchor.constraint(equalToConstant: Dimensions.imageWidth),
            imageView.widthAnchor.constraint(equalToConstant: Dimensions.imageWidth),

            labelContainer.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Dimensions.verticalContainerMargin),
            labelContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Dimensions.horizontalMargin),
            labelContainer.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -Dimensions.verticalContainerMargin)
        ])
    }
}
