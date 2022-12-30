//
//  EmojiChooser.swift
//  VocabularyTrainer
//
//  Created by skrr on 30.12.22.
//  Copyright © 2022 mic. All rights reserved.
//

import Foundation

enum EmojiChooser {

    private static let emojiRanges = [
        0x1F601...0x1F64F,
//        0x2702...0x27B0,
        0x1F680...0x1F6C0
//        0x1F170...0x1F251
    ]

    static var choose: String {
        var retVal = ""
        guard let range = emojiRanges.randomElement() else { return "" }
            guard let randomI = range.randomElement(),
                  let scalar = UnicodeScalar(randomI) else { return "" }
        retVal = String(scalar)
        return retVal
    }
}
