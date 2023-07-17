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

    func localize() -> String {
        return NSLocalizedString(self.rawValue, comment: "")
    }
}
