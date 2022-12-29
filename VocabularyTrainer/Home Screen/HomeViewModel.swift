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

//    let data: [LanguageCellViewModel] = [
//        .init(languageName: "Greek", numberOfWords: 122),
//        .init(languageName: "German", numberOfWords: 314),
//        .init(languageName: "English", numberOfWords: 426),
//        .init(languageName: "Korean", numberOfWords: 231)
//    ]

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
