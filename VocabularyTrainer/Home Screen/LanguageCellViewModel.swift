//
//  LanguageCellViewModel.swift
//  VocabularyTrainer
//
//  Created by skrr on 18.12.22.
//  Copyright © 2022 mic. All rights reserved.
//

import Foundation

struct LanguageCellViewModel: Hashable {
    let id = UUID()
    let languageName: String
    let numberOfWords: Int
    // To be implemented
    let emoji: String = ""
}
