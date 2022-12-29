//
//  HomeViewModel.swift
//  VocabularyTrainer
//
//  Created by skrr on 18.12.22.
//  Copyright © 2022 mic. All rights reserved.
//

import UIKit

final class HomeViewModel {
    var coordinator: MainCoordinator?

    var data: [LanguageCellViewModel] {
        var retVal: [LanguageCellViewModel] = []
        if let languages = UserDefaults.standard.array(forKey: UserDefaultKeys.languages) as? [String] {
            retVal = languages.map {
                let languageDict = UserDefaults.standard.dictionary(forKey: $0) as? [String: String]
                return LanguageCellViewModel(languageName: $0, numberOfWords: languageDict?.count ?? 0)
            }
        }
        return retVal
    }

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
                return rowModel.labelsHeight(with: width)
            }
        )

        return WaterfallTrueCompositionalLayout.makeLayoutSection(
            config: configuration,
            environment: environment,
            sectionIndex: sectionIndex
        )
    }

    init(coordinator: MainCoordinator?) {
        self.coordinator = coordinator
    }

    enum Strings {
        static let headerTitle = "My Languages"
        static let practiceButtonTitle = "Practice"
        static let editButtonTitle = "Edit"
    }

    enum Colors {
        static let background = UIColor.secondarySystemBackground
        static let title = UIColor.label
        static let subtitle = UIColor.secondaryLabel
        static let flippyGreen = UIColor(named: "flippyGreen")
    }
}
