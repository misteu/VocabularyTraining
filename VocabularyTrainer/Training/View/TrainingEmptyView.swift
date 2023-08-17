//
//  TrainingEmptyView.swift
//  VocabularyTrainer
//
//  Created by Mariana Brasil on 30/07/23.
//  Copyright © 2023 mic. All rights reserved.
//

import UIKit

// MARK: - Delegate
protocol TrainingEmptyViewDelegate: AnyObject {
    func tappedBarButton()
}

final class TrainingEmptyView: UIView {

    typealias Colors = HomeViewModel.Colors

    weak var delegate: TrainingEmptyViewDelegate?

    // MARK: - Private properties

    /// Bar button to drag/close the view
    private lazy var barButton: UIButton = {
        let button = ModalCloseButton()
        button.addTarget(self,
                         action: #selector(tappedBarButton),
                         for: .touchUpInside)
        return button
    }()

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
                                                   text: Localizable.emptyWord.localize(),
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
        addSubviews([barButton, imageView, emptyLabel])
        startAnimation()
        translatesAutoresizingMaskIntoConstraints = false
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            barButton.topAnchor.constraint(equalTo: self.topAnchor, constant: 16),
            barButton.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            barButton.heightAnchor.constraint(equalToConstant: 5),
            barButton.widthAnchor.constraint(equalToConstant: 40),

            imageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            imageView.topAnchor.constraint(equalTo: barButton.bottomAnchor, constant: 36),
            imageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            imageView.heightAnchor.constraint(equalToConstant: 70),
            imageView.widthAnchor.constraint(equalToConstant: 80),

            emptyLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 24),
            emptyLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 28),
            emptyLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -24),
            emptyLabel.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
    }

    private func startAnimation() {
        UIView.animate(withDuration: 1, animations: { [weak self] in
            self?.imageView.frame.origin.y -= 5
        }){ [weak self] _ in
            UIView.animateKeyframes(withDuration: 1, delay: 0.1, options: [.autoreverse, .repeat], animations: {
                self?.imageView.frame.origin.y += 5
            })
        }
    }

    @objc private func tappedBarButton(){
        delegate?.tappedBarButton()
    }
}
