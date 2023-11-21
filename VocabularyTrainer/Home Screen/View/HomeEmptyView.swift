//
//  HomeEmptyView.swift
//  VocabularyTrainer
//
//  Created by Mariana Brasil on 30/07/23.
//  Copyright © 2023 mic. All rights reserved.
//

import UIKit

final class HomeEmptyView: UIView {

    typealias Colors = HomeViewModel.Colors

    /// Image view showing the sad robot image.
    private let imageView: UIImageView = {
        let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.contentMode = .scaleAspectFit
        view.image = UIImage(named: "SadRobot")
        view.clipsToBounds = true
        view.isAccessibilityElement = false
        return view
    }()

    /// Empty label when the user don't have any language added.
    private lazy var emptyLabel: UILabel = .createLabel(font: UIFontMetrics(forTextStyle: .body)
        .scaledFont(for: .systemFont(ofSize: 14, weight: .regular)),
                                                   text: NSLocalizedString("emptyLanguage", comment: ""),
                                                        fontColor: Colors.subtitle,
                                                        textAlignment: .center)

    // MARK: - Initializer

    init() {
        super.init(frame: .zero)
        setupUI()
        setupConstraints()
    }

    required init?(coder: NSCoder) { nil }

    // MARK: - Setup

    private func setupUI() {
        addSubviews([imageView, emptyLabel])
        translatesAutoresizingMaskIntoConstraints = false
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            imageView.topAnchor.constraint(equalTo: topAnchor),
            imageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            imageView.heightAnchor.constraint(equalToConstant: 70),
            imageView.widthAnchor.constraint(equalToConstant: 80),

            emptyLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            emptyLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 28),
            emptyLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            emptyLabel.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
    }

    public func startAnimation() {
        UIView.animate(withDuration: 1, animations: { [weak self] in
            self?.imageView.frame.origin.y -= 5
        }){ [weak self] _ in
            UIView.animateKeyframes(withDuration: 1, delay: 0.1, options: [.autoreverse, .repeat], animations: {
                self?.imageView.frame.origin.y += 5
            })
        }
    }
}
