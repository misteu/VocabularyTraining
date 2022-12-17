//
//  String+Extension.swift
//  VocabularyTrainer
//
//  Created by Mariana Brasil on 17/12/22.
//  Copyright © 2022 mic. All rights reserved.
//

import UIKit

extension String {
    func isEmptyOrWhitespace() -> Bool {
        if self.isEmpty {
            return true
        }

        return (self.trimmingCharacters(in: .whitespaces) == "")
    }
}
