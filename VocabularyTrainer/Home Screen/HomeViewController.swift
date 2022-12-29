//
//  HomeViewController.swift
//  VocabularyTrainer
//
//  Created by skrr on 18.12.22.
//  Copyright © 2022 mic. All rights reserved.
//

import Foundation
import UIKit

class HomeViewController: UIViewController {

    typealias Colors = HomeViewModel.Colors

    // MARK: - Private

    private let viewModel: HomeViewModel
    private let headerView: HomeLanguageHeaderView
    /// The currently selected index path.
    private var selectedIndexPath: IndexPath? {
        collectionView.indexPathsForSelectedItems?.first
    }
    /// The currently selected language.
    private var selectedLanguage: String? {
        guard let selectedIndexPath = selectedIndexPath,
              viewModel.data.indices.contains(selectedIndexPath.row) else { return nil }
        return viewModel.data[selectedIndexPath.row].languageName
    }

    private lazy var collectionView: UICollectionView = {
        var listConfiguration = UICollectionViewCompositionalLayoutConfiguration()

        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: .init())
        collectionView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        collectionView.backgroundColor = HomeViewModel.Colors.background
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()

    lazy var datasource: UICollectionViewDiffableDataSource<Int, LanguageCellViewModel> = { [weak self] in

        let cellConfig = UICollectionView.CellRegistration<CollectionViewCell, LanguageCellViewModel> { cell, _, item in
            cell.configure(with: item)
        }

        let datasource = UICollectionViewDiffableDataSource<Int, LanguageCellViewModel>(collectionView: collectionView) { collectionView, indexPath, model in
            let configType = cellConfig
            return collectionView.dequeueConfiguredReusableCell(using: configType,
                                                                for: indexPath,
                                                                item: model)
        }
        return datasource
    }()
    
    /// Width of leading and trailing margins around `collectionView`.
    private let horizontalCollectionViewMargins: CGFloat = 24

    // MARK: - Init

    init(viewModel: HomeViewModel) {
        self.viewModel = viewModel
        self.headerView = HomeLanguageHeaderView()
        super.init(nibName: nil, bundle: nil)
        headerView.delegate = self
        collectionView.delegate = self
        setupView()
    }

    required init?(coder: NSCoder) { nil }

    // MARK: - Private Methods

    private func setupView() {
        view.backgroundColor = HomeViewModel.Colors.background
        view.addSubview(collectionView)
        view.addSubview(headerView)

        collectionView.setCollectionViewLayout(viewModel.layout, animated: true)

        NSLayoutConstraint.activate([
            headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: horizontalCollectionViewMargins),
            headerView.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor),
            headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -horizontalCollectionViewMargins),

            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: horizontalCollectionViewMargins),
            collectionView.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 24),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -horizontalCollectionViewMargins),
            collectionView.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor)
        ])
        applyCollectionViewChanges()
    }

    /// Applies changes of data source.
    private func applyCollectionViewChanges() {
        var snap = datasource.snapshot()
        if !snap.sectionIdentifiers.isEmpty {
            snap.deleteSections([0])
        }
        snap.appendSections([0])
        snap.appendItems(viewModel.data)
        datasource.apply(snap)
    }
}

extension HomeViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print(viewModel.data[indexPath.row].languageName)
    }
}

// MARK: - HomeLanguageHeaderViewDelegate

extension HomeViewController: HomeLanguageHeaderViewDelegate {
    func tappedAddLanguageButton() {
        print("tapped add language")
        viewModel.coordinator?.navigateToNewLanguageViewController(newLanguageScreenProtocol: self)
    }

    func tappedPracticeButton() {
        print("tapped practice")
        guard let selectedLanguage = selectedLanguage else { return }
        viewModel.coordinator?.navigateToTrainingViewController(with: selectedLanguage)
    }

    func tappedEditButton() {
        print("tapped edit")
        guard let selectedLanguage = selectedLanguage else { return }
        viewModel.coordinator?.navigateToLanguageScreenViewController(
            selectedLanguage: selectedLanguage,
            newLanguageScreenProtocol: self,
            completion: { [weak self] in
                self?.applyCollectionViewChanges()
            })
    }
}

extension HomeViewController: NewLanguageScreenProtocol {
    func updateLanguageTable(language: String) {
        debugPrint("\(language) added/deleted")
        self.applyCollectionViewChanges()
    }
}
