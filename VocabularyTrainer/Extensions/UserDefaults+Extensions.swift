//
//  UserDefaults+Extensions.swift
//  VocabularyTrainer
//
//  Created by skrr on 30.12.22.
//  Copyright © 2022 mic. All rights reserved.
//

import Foundation

enum UserDefaultKeys {
    static let languages = "languages"
    static func languageIcon(for language: String) -> String {
        "\(language)Icon"
    }
}

extension UserDefaults {
    func languageEmoji(for language: String) -> String? {
        string(forKey: UserDefaultKeys.languageIcon(for: language))
    }

    func setLanguageEmoji(for language: String, emoji: String) {
        set(emoji, forKey: UserDefaultKeys.languageIcon(for: language))
    }
}
