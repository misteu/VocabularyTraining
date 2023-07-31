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

    private lazy var trainingView: TrainingView = .init(selectedLanguage: selectedLanguage)

    private lazy var emptyView: TrainingEmptyView = .init()

    private var isWordsEmpty: Bool {
        guard let dictionary = UserDefaults.standard.dictionary(forKey: selectedLanguage) else { return true }
        return false
    }

    // MARK: - Init

    init(with language: String) {
      self.selectedLanguage = language
      super.init(nibName: nil, bundle: nil)
        setUpUI()
        hideKeyboardWhenTappedAround()
    }

    required init?(coder: NSCoder) { nil }

    // MARK: - Private Methods

    private func setUpUI() {
        view.backgroundColor = .systemBackground
        isWordsEmpty ? setUpEmptyView() : setUpSuccessView()
    }

    private func setUpSuccessView() {
        view.addSubview(trainingView)
        trainingView.delegate = self
        trainingView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            trainingView.topAnchor.constraint(equalTo: view.topAnchor),
            trainingView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            trainingView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            trainingView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    private func setUpEmptyView() {
        view.addSubview(emptyView)
        emptyView.delegate = self
        emptyView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            emptyView.topAnchor.constraint(equalTo: view.topAnchor),
            emptyView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            emptyView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
    }
}

extension TrainingViewController: TrainingViewDelegate, TrainingEmptyViewDelegate {
    func tappedBarButton() {
        dismiss(animated: true)
    }
}
