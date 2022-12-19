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

    // MARK: - Private

    private let viewModel: HomeViewModel

    private lazy var collectionView: UICollectionView = {
        var listConfiguration = UICollectionViewCompositionalLayoutConfiguration()

        let layout = makeCollectionViewLayout()
        let collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: layout)
        collectionView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        collectionView.backgroundColor = HomeViewModel.Colors.background
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()

    lazy var datasource: UICollectionViewDiffableDataSource<Int, LanguageCellViewModel> = {
        let cellConfig = UICollectionView.CellRegistration<UICollectionViewListCell, LanguageCellViewModel> { cell, _, model in
            var contentConfiguration = cell.defaultContentConfiguration()
            contentConfiguration.text = model.languageName
            contentConfiguration.textProperties.font = .preferredFont(forTextStyle: .headline)
            contentConfiguration.textProperties.color = HomeViewModel.Colors.title
            contentConfiguration.secondaryText = "\(model.numberOfWords) words"
            contentConfiguration.secondaryTextProperties.font = .preferredFont(forTextStyle: .body)
            contentConfiguration.secondaryTextProperties.color = HomeViewModel.Colors.subtitle
            contentConfiguration.image = UIImage(systemName: "hare")
            cell.contentConfiguration = contentConfiguration
            cell.backgroundConfiguration?.backgroundColor = .systemBackground
            cell.backgroundConfiguration?.cornerRadius = 7
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
    /// Title label above the collection view.
    let titleLabel = UILabel()
    /// Container for title label and buttons above `collectionView`.
    let titleContainer = UIView()

    // MARK: - Init

    init(viewModel: HomeViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        setView()
        setTitleContainer()
    }

    required init?(coder: NSCoder) { nil }

    // MARK: - Private Methods

    private func setView() {
        view.backgroundColor = HomeViewModel.Colors.background
        view.addSubview(collectionView)
        titleContainer.addSubview(titleLabel)
        view.addSubview(titleContainer)

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleContainer.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: titleContainer.leadingAnchor),
            titleLabel.topAnchor.constraint(equalTo: titleContainer.topAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: titleContainer.bottomAnchor),

            titleContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: horizontalCollectionViewMargins),
            titleContainer.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor),
            titleContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: horizontalCollectionViewMargins),

            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: horizontalCollectionViewMargins),
            collectionView.topAnchor.constraint(equalTo: titleContainer.bottomAnchor, constant: 24),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -horizontalCollectionViewMargins),
            collectionView.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor)
        ])

        var snap = datasource.snapshot()
        snap.appendSections([0])
        snap.appendItems(viewModel.data)
        datasource.apply(snap)
    }

    private func setTitleContainer() {
        titleLabel.font = UIFontMetrics(forTextStyle: .title2).scaledFont(for: .systemFont(ofSize: 24))
        titleLabel.text = viewModel.title
    }

    private func makeCollectionViewLayout() -> UICollectionViewLayout {
        let horizontalMargins = 2 * horizontalCollectionViewMargins
        let interItemSpacing: CGFloat = Layout.defaultMargin
        let itemSize = NSCollectionLayoutSize(widthDimension: .absolute((UIScreen.main.bounds.width - horizontalMargins - interItemSpacing) / 2),
                                              heightDimension: .fractionalHeight(1.0))
        let items = (0...1).map { _ in NSCollectionLayoutItem(layoutSize: itemSize) }
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                               heightDimension: .absolute(59))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize,
                                                       subitems: items)
        group.interItemSpacing = .fixed(interItemSpacing)
        group.edgeSpacing = .init(leading: .fixed(0), top: .fixed(Layout.defaultMargin / 4), trailing: .fixed(0), bottom: .fixed(Layout.defaultMargin / 4))
        let section = NSCollectionLayoutSection(group: group)
        let layout = UICollectionViewCompositionalLayout(section: section)

        return layout
    }
}
