//
//  Localizable.swift
//  VocabularyTrainer
//
//  Created by Mariana Brasil on 16/12/22.
//  Copyright © 2022 mic. All rights reserved.
//

import UIKit

enum Localizable: String {

    case close
    case addNewLanguage
    case whichLanguage
    case language
    case languageExists
    case add
    case translation
    case answer
    case check
    case nextWord
    case emptyLanguage
    case emptyWord
    case skip
    case takeLook
    case addedLanguage
    case wrongAnswer
    case rightAnswer
	case correctButtonTitle
	case wrongButtonTitle

    func localize() -> String {
        return NSLocalizedString(self.rawValue, comment: "")
    }
}
