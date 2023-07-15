//
//  TrainingViewController.swift
//  VocabularyTrainer
//
//  Created by Mariana Brasil on 04/02/23.
//  Copyright © 2023 mic. All rights reserved.
//

import UIKit

final class TrainingViewController: UIViewController {

    // MARK: - Public properties

    weak var coordinator: MainCoordinator?

    // MARK: - Private properties

    private let selectedLanguage: String

    private lazy var trainingView: UIView = TrainingView(selectedLanguage: selectedLanguage)

    // MARK: - Init

    init(with language: String) {
      self.selectedLanguage = language
      super.init(nibName: nil, bundle: nil)
        setUpUI()
        setUpConstraints()
        hideKeyboardWhenTappedAround()
    }

    required init?(coder: NSCoder) { nil }

    // MARK: - Private Methods

    private func setUpUI() {
        view.addSubview(trainingView)
        view.backgroundColor = .systemBackground
        trainingView.translatesAutoresizingMaskIntoConstraints = false
    }

    private func setUpConstraints() {
        NSLayoutConstraint.activate([
            trainingView.topAnchor.constraint(equalTo: view.topAnchor),
            trainingView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            trainingView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            trainingView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
}
