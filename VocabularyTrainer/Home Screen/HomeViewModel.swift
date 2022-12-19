//
//  HomeViewModel.swift
//  VocabularyTrainer
//
//  Created by skrr on 18.12.22.
//  Copyright © 2022 mic. All rights reserved.
//

import UIKit

struct HomeViewModel {
    var coordinator: MainCoordinator?
    let title = "My Languages"

    let data: [LanguageCellViewModel] = [
        .init(languageName: "Greek", numberOfWords: 122),
        .init(languageName: "German", numberOfWords: 314),
        .init(languageName: "English", numberOfWords: 426),
        .init(languageName: "Korean", numberOfWords: 231)
    ]

    enum Colors {
        static let background = UIColor.secondarySystemBackground
        static let title = UIColor.label
        static let subtitle = UIColor.secondaryLabel
    }
}
