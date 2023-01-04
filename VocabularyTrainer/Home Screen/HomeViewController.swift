//
//  HomeViewController.swift
//  VocabularyTrainer
//
//  Created by Michael Steudter on 18.12.22.
//  Copyright © 2022 mic. All rights reserved.
//

import UIKit

/// The home screen, showing tiles for each saved language in a waterfall style layout.
final class HomeViewController: UIViewController {

    typealias Colors = HomeViewModel.Colors
    typealias Strings = HomeViewModel.Strings

    // MARK: - Private

    /// The view model.
    private let viewModel: HomeViewModel
    /// The header view shown above `collectionView`.
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
    /// The collection view showing all the languages.
    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: .init())
        collectionView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        collectionView.backgroundColor = HomeViewModel.Colors.background
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    /// Data source of `collectionView`.
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
    /// Colored Flippy logo shown at the leading side of the home screen's navbar.
    private let navbarLogo: UIBarButtonItem = {
        let label = UILabel()
        let text = NSMutableAttributedString(
            string: "Flippy ",
            attributes: [.foregroundColor: Colors.flippyGreen as Any]
        )
        text.append(.init(string: "Learn"))
        label.attributedText = text
        return UIBarButtonItem(customView: label)
    }()
    /// Button for opening the about page of the app.
    private lazy var aboutButton: UIButton = {
        UIButton.aboutButton { [weak self] in
            guard let self = self else { return }
            let navigationController = UINavigationController(rootViewController: self.aboutViewController)
            self.present(navigationController, animated: true, completion: nil)
        }
    }()

    let aboutViewController = AboutViewController()

    // MARK: - Init

    init(viewModel: HomeViewModel) {
        self.viewModel = viewModel
        self.headerView = HomeLanguageHeaderView()
        super.init(nibName: nil, bundle: nil)
        headerView.delegate = self
        setNavigationItem()
        setupView()
    }

    required init?(coder: NSCoder) { nil }

    // MARK: - View Lifecycle

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        removeNavigationBarBackground()
    }

    // MARK: - Private Methods

    private func setupView() {
        view.backgroundColor = HomeViewModel.Colors.background
        view.addSubview(headerView)
        view.addSubview(collectionView)
        view.addSubview(aboutButton)

        collectionView.setCollectionViewLayout(viewModel.layout, animated: true)

        NSLayoutConstraint.activate([
            headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: horizontalCollectionViewMargins),
            headerView.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor, constant: Layout.defaultMargin),
            headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -horizontalCollectionViewMargins),

            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: horizontalCollectionViewMargins),
            collectionView.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 24),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -horizontalCollectionViewMargins),
            collectionView.bottomAnchor.constraint(equalTo: aboutButton.topAnchor, constant: Layout.defaultMargin * 2),

            aboutButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            aboutButton.leadingAnchor.constraint(greaterThanOrEqualTo: view.layoutMarginsGuide.leadingAnchor, constant: Layout.defaultMargin),
            aboutButton.trailingAnchor.constraint(lessThanOrEqualTo: view.layoutMarginsGuide.trailingAnchor, constant: -Layout.defaultMargin),
            aboutButton.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor, constant: -Layout.defaultMargin),
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

    /// Sets `navigationItem` with Flippy logo and import/export buttons.
    private func setNavigationItem() {
        navigationItem.leftBarButtonItem = navbarLogo
        let importButton = UIBarButtonItem(
            customView: UIButton.iconButton(type: .importButton) { [weak self] in
                self?.tappedImport()
            }
        )
        let exportButton = UIBarButtonItem(
            customView: UIButton.iconButton(type: .exportButton) { [weak self] in
                self?.tappedExport()
            }
        )
        navigationItem.rightBarButtonItems = [exportButton, importButton]
    }
}

// MARK: - HomeLanguageHeaderViewDelegate

extension HomeViewController: HomeLanguageHeaderViewDelegate {
    func tappedAddLanguageButton() {
        viewModel.coordinator?.navigateToNewLanguageViewController(newLanguageScreenProtocol: self)
    }

    func tappedPracticeButton() {
        guard let selectedLanguage = selectedLanguage else { return }
        viewModel.coordinator?.navigateToTrainingViewController(with: selectedLanguage)
    }

    func tappedEditButton() {
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
        self.applyCollectionViewChanges()
    }
}

// MARK: - Import / Export
// TODO: Move to iCloud Export / Import later

extension HomeViewController {

    private func tappedImport() {
        guard let files = ExportImport.getAllLanguageFileUrls() else { return }

        if files.isEmpty {
            let message = """
        There were not found any language files for your app.\nFor a template of a language file you may create a new language with some vocabulary inside this app and export it.
      """
            let alert = UIAlertController(
                title: NSLocalizedString("No language files found",
                                         comment: "No language files found"),
                message: NSLocalizedString(message, comment: message),
                preferredStyle: UIAlertController.Style.alert)

            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        } else {
            ExportImport.importLanguageFiles(files)
            applyCollectionViewChanges()
        }
    }

    private func tappedExport() {
        if let selectedLanguage = selectedLanguage {

            let words = ExportImport.exportAsCsvToDocuments(language: selectedLanguage)
            let ac = UIActivityViewController(activityItems: [words], applicationActivities: nil)
            present(ac, animated: true)
        } else {
            let alert = UIAlertController(title: NSLocalizedString("No language selected",
                                                                   comment: "Title for popup when no language was selected"),
                                          message: NSLocalizedString("Please select a language to export first.", comment: "Text for no-language-selected popup."),
                                          preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            present(alert, animated: true, completion: nil)
        }
    }
}
