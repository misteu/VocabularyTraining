//
//  LanguageImport.swift
//  VocabularyTrainer
//
//  Created by skrr on 18.12.22.
//  Copyright © 2022 mic. All rights reserved.
//

import Foundation

struct LanguageImport {
    var vocabularies: [String: String]
    var progresses: [String: Float]
    var datesAdded = [String: Date]()

    init(vocabularies: [String: String],
         progresses: [String: Float],
         datesAdded: [String: Date]) {
        self.vocabularies = vocabularies
        self.progresses = progresses
        self.datesAdded = datesAdded
    }
}
