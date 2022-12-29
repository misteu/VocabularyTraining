//
//  String+Extensions.swift
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

    func height(withConstrainedWidth width: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect,
                                            options: .usesLineFragmentOrigin,
                                            attributes: [.font: font],
                                            context: nil)

        return ceil(boundingBox.height)
    }

    func width(withConstrainedHeight height: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: .greatestFiniteMagnitude, height: height)
        let boundingBox = self.boundingRect(with: constraintRect,
                                            options: .usesLineFragmentOrigin,
                                            attributes: [.font: font],
                                            context: nil)

        return ceil(boundingBox.width)
    }
}
