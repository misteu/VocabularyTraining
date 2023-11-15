//
//  HomeViewController.swift
//  VocabularyTrainer
//
//  Created by Michael Steudter on 18.12.22.
//  Copyright © 2022 mic. All rights reserved.
//

import UIKit
import UniformTypeIdentifiers

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
    /// If don't find any languages the isEmpty returns true
    private var isLanguagesEmpty: Bool {
        viewModel.data.isEmpty
    }
    /// The currently selected language.
    private var selectedLanguage: String? {
        guard let selectedIndexPath = selectedIndexPath,
              viewModel.data.indices.contains(selectedIndexPath.row) else { return nil }
        return viewModel.data[selectedIndexPath.row].languageName
    }
    /// The last index path selected.
    private var selectedLastIndexPath: Int?

    private var accessibilityActions: [UIAccessibilityCustomAction]? {
        let practiceAction = UIAccessibilityCustomAction(name: HomeViewModel.Strings.practiceButtonTitle,
                                                         target: self,
                                                         selector: #selector(practiceButtonAction))
        let editAction = UIAccessibilityCustomAction(name: HomeViewModel.Strings.editButtonTitle,
                                                     target: self,
                                                     selector: #selector(editButtonAction))
		let importAction = UIAccessibilityCustomAction(name: HomeViewModel.Strings.importButtonTitle) { _ in
			self.selectFiles()
			return true
		}
        let exportAction = UIAccessibilityCustomAction(name: HomeViewModel.Strings.exportButtonTitle,
                                                       target: self,
                                                       selector: #selector(tappedExport))
        return [practiceAction, editAction, importAction, exportAction]
    }

    /// The empty view that will be displayed when there is no language added.
    private lazy var emptyView: HomeEmptyView = .init()
    /// The collection view showing all the languages.
    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: .init())
        collectionView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        collectionView.backgroundColor = HomeViewModel.Colors.background
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.delegate = self
        return collectionView
    }()
    /// Data source of `collectionView`.
    lazy var datasource: UICollectionViewDiffableDataSource<Int, LanguageCellViewModel> = { [self] in
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
    private let horizontalCollectionViewMargins: CGFloat = 16
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
    }

    required init?(coder: NSCoder) { nil }

    // MARK: - View Lifecycle

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        removeNavigationBarBackground()
        selectedLastIndexPath = nil
        headerView.shouldHideHeaderButtons(true)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        UIAccessibility.focusOn(navbarLogo)
        setNavigationItem()
        setupView()
        setConstraints()
        setEmptyState()
        applyCollectionViewChanges()
    }

    // MARK: - Private Methods

    private func setupView() {
        view.backgroundColor = HomeViewModel.Colors.background
        view.addSubviews([headerView, collectionView])
        if isLanguagesEmpty {
            view.addSubview(emptyView)
        }
        view.addSubview(aboutButton)
        collectionView.setCollectionViewLayout(viewModel.layout, animated: true)
    }

    private func setConstraints() {
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
            aboutButton.widthAnchor.constraint(greaterThanOrEqualToConstant: 110),
            aboutButton.heightAnchor.constraint(greaterThanOrEqualToConstant: 28)
        ])
    }

    private func setEmptyState() {
        guard isLanguagesEmpty else { return }

        if isLanguagesEmpty {
            emptyView.startAnimation()
        }

        NSLayoutConstraint.activate([
            emptyView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: horizontalCollectionViewMargins),
            emptyView.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 24),
            emptyView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -horizontalCollectionViewMargins),
        ])
    }

    /// Applies changes of data source.
	func applyCollectionViewChanges() {
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
				self?.selectFiles()
            }
        )
        let exportButton = UIBarButtonItem(
            customView: UIButton.iconButton(type: .exportButton) { [weak self] in
                self?.tappedExport()
            }
        )
        navigationItem.rightBarButtonItems = [exportButton, importButton]
    }

    private func deselectCell(_ collectionView: UICollectionView, indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        collectionView.cellForItem(at: indexPath)?.contentView.accessibilityTraits.remove(.selected)
        collectionView.cellForItem(at: indexPath)?.contentView.accessibilityCustomActions = nil
        headerView.shouldHideHeaderButtons(true)
        selectedLastIndexPath = nil
    }

    @objc private func practiceButtonAction() {
        guard let selectedLanguage = selectedLanguage else { return }
        viewModel.coordinator?.navigateToTrainingViewController(with: selectedLanguage)
        selectedHapticFeedback()
    }

    @objc private func editButtonAction() {
        guard let selectedLanguage = selectedLanguage else { return }
        viewModel.coordinator?.navigateToLanguageScreenViewController(
            selectedLanguage: selectedLanguage,
            newLanguageScreenProtocol: self,
            completion: { [weak self] in
                self?.applyCollectionViewChanges()
            })
        selectedHapticFeedback()
    }
}

// MARK: - HomeLanguageHeaderViewDelegate

extension HomeViewController: HomeLanguageHeaderViewDelegate {
    func tappedAddLanguageButton() {
        viewModel.coordinator?.navigateToNewLanguageViewController(newLanguageScreenProtocol: self)
        selectedHapticFeedback()
    }

    func tappedPracticeButton() {
        practiceButtonAction()
    }

    func tappedEditButton() {
        editButtonAction()
    }
}

extension HomeViewController: NewLanguageScreenProtocol {
    func updateLanguageTable(language: String) {
        viewDidLoad()
        applyCollectionViewChanges()
    }
}

extension HomeViewController: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if selectedLastIndexPath == indexPath.row {
            deselectCell(collectionView, indexPath: indexPath)
        } else {
            headerView.shouldHideHeaderButtons(false)
            let cell = collectionView.cellForItem(at: indexPath)?.contentView
            cell?.accessibilityTraits.insert(.selected)
            cell?.accessibilityCustomActions = accessibilityActions
            selectedLastIndexPath = indexPath.row
        }
        selectedHapticFeedback()
    }

    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        deselectCell(collectionView, indexPath: indexPath)
    }
}

// MARK: - Import / Export
// TODO: Move to iCloud Export / Import later

extension HomeViewController {

    @objc private func tappedExport() {
        if let selectedLanguage = selectedLanguage {

            let words = ExportImport.exportAsCsvToDocuments(language: selectedLanguage)
			
			guard let cacheURL = saveStringAsCSVToCacheDirectory(words, fileName: selectedLanguage) else { return }
			
            let ac = UIActivityViewController(activityItems: [cacheURL], applicationActivities: nil)
            present(ac, animated: true)
            successHapticFeedback()
        } else {
            let alert = UIAlertController(title: NSLocalizedString("No language selected",
                                                                   comment: "Title for popup when no language was selected"),
                                          message: NSLocalizedString("Please select a language to export first.", comment: "Text for no-language-selected popup."),
                                          preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            present(alert, animated: true, completion: nil)
            errorHapticFeedback()
        }
    }

    private func selectedHapticFeedback() {
        let generator = UISelectionFeedbackGenerator()
        generator.selectionChanged()
    }

    private func successHapticFeedback() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }

    private func errorHapticFeedback() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.error)
    }

	private func saveStringAsCSVToCacheDirectory(_ inputString: String, fileName: String) -> URL? {
		// Get the cache directory URL
		if let cacheDirectoryURL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first {
			// Create a URL for the CSV file
			let csvFileURL = cacheDirectoryURL.appendingPathComponent(fileName).appendingPathExtension("csv")

			do {
				// Write the inputString to the CSV file
				try inputString.write(to: csvFileURL, atomically: true, encoding: .utf8)
				return csvFileURL // Return the URL to the saved CSV file
			} catch {
				print("Error saving CSV file: \(error)")
			}
		}

		return nil
	}
}

extension HomeViewController: UIDocumentPickerDelegate {
	func selectFiles() {
		let types = UTType.types(tag: "csv",
								 tagClass: UTTagClass.filenameExtension,
								 conformingTo: nil)
		let documentPickerController = UIDocumentPickerViewController(
				forOpeningContentTypes: types)
		documentPickerController.delegate = self
		self.present(documentPickerController, animated: true, completion: nil)
	}
	
	func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
		ExportImport.importLanguageFiles(urls, presentingViewController: self)
	}
}
