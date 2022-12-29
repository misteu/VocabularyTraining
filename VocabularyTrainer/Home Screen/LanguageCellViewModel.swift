//
//  LanguageCellViewModel.swift
//  VocabularyTrainer
//
//  Created by skrr on 18.12.22.
//  Copyright © 2022 mic. All rights reserved.
//

import UIKit

struct LanguageCellViewModel: Hashable {
    let id = UUID()
    let languageName: String
    let numberOfWords: Int
    // To be implemented
    let emoji: String = ""

    var subtitle: String {
        String(format: LanguageCellViewModel.Strings.numberOfWordsTitle, numberOfWords)
    }

    func labelsHeight(with width: CGFloat) -> CGFloat {
        let finalWidth = width - Self.Dimensions.imageWidth - 3 * Self.Dimensions.horizontalMargin
        let titleHeight = languageName.height(withConstrainedWidth: finalWidth,
                                              font: .preferredFont(forTextStyle: .headline))
        let subtitleHeight = subtitle.height(withConstrainedWidth: finalWidth,
                                             font: .preferredFont(forTextStyle: .body))
        return titleHeight + subtitleHeight + Self.Dimensions.verticalMargins
    }
}

// MARK: - Static Data

extension LanguageCellViewModel {
    enum Dimensions {
        static let imageWidth: CGFloat = 36
        static let labelSpacing: CGFloat = 2
        static let horizontalMargin: CGFloat = Layout.defaultMargin / 2
        static let verticalContainerMargin: CGFloat = Layout.defaultMargin / 2
        fileprivate static let verticalMargins = 2 * verticalContainerMargin + labelSpacing
        static let cornerRadius: CGFloat = 7
    }

    enum Strings {
        static let numberOfWordsTitle = NSLocalizedString(
            "homescreen_language_subtitle",
            value: "Words: %i",
            comment: "Subtitle of a cell on the home screen showing the word count of a language."
        )
    }

    enum Colors {
        static let cellBackground = UIColor.systemBackground
        static let selectedCellBackground = UIColor(red: 0.685, green: 0.95, blue: 0.861, alpha: 1)
    }
}
