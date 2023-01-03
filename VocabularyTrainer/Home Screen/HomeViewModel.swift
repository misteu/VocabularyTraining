//
//  HomeViewModel.swift
//  VocabularyTrainer
//
//  Created by skrr on 18.12.22.
//  Copyright © 2022 mic. All rights reserved.
//

import UIKit
import WaterfallTrueCompositionalLayout

/// View model for the home screen.
final class HomeViewModel {
    /// Coordinator managing the navigation
    var coordinator: MainCoordinator?

    /// The data (language tiles) shown in the home screen's collection view.
    var data: [LanguageCellViewModel] {
        var retVal: [LanguageCellViewModel] = []
        if let languages = UserDefaults.standard.array(forKey: UserDefaultKeys.languages) as? [String] {
            retVal = languages.map {
                let languageDict = UserDefaults.standard.dictionary(forKey: $0) as? [String: String]
                let emoji = UserDefaults.standard.languageEmoji(for: $0) ?? ""
                return LanguageCellViewModel(languageName: $0,
                                             numberOfWords: languageDict?.count ?? 0,
                                             emoji: emoji)
            }
        }
        return retVal
    }

    /// Layout for the collection view on the home screen.
    lazy var layout = UICollectionViewCompositionalLayout { sectionIndex, environment in
        let configuration = WaterfallTrueCompositionalLayout.Configuration(
            columnCount: 2,
            interItemSpacing: 8,
            contentInsetsReference: .automatic,
            itemCountProvider: { [weak self] in
                return self?.data.count ?? 0
            },
            itemHeightProvider: { [weak self] row, width in
                guard let self = self,
                    self.data.indices.contains(row) else { return .zero }
                let rowModel = self.data[row]
                return rowModel.requiredCellHeight(with: width)
            }
        )

        return WaterfallTrueCompositionalLayout.makeLayoutSection(
            config: configuration,
            environment: environment,
            sectionIndex: sectionIndex
        )
    }

    // MARK: - Init

    init(coordinator: MainCoordinator?) {
        self.coordinator = coordinator
    }

    // MARK: - Static Data

    enum Strings {
        static let headerTitle = NSLocalizedString("home_header_title", comment: "Title of the header above the language tiles")
        static let practiceButtonTitle = NSLocalizedString("home_practice_button_title", comment: "Title of the button for starting practicing")
        static let editButtonTitle = NSLocalizedString("home_edit_button_title", comment: "Title of the button for editing a language")
        static let importButtonTitle = NSLocalizedString("home_import_button_title", comment: "Title of the button for importing saved languages")
        static let exportButtonTitle = NSLocalizedString("home_export_button_title", comment: "Title of the button for exporting saved languages")
    }

    enum Colors {
        static let background = UIColor.secondarySystemBackground
        static let title = UIColor.label
        static let subtitle = UIColor.secondaryLabel
        static let flippyGreen = UIColor(named: "flippyGreen")
    }
}
