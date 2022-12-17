//
//  UILabel+Extension.swift
//  VocabularyTrainer
//
//  Created by Mariana Brasil on 16/12/22.
//  Copyright © 2022 mic. All rights reserved.
//

import UIKit

extension UILabel {
    static func createLabel(font: UIFont? = .systemFont(ofSize: 16, weight: .regular),
                            text: String,
                            isHidden: Bool = false,
                            accessibilityTrait: UIAccessibilityTraits = .staticText,
                            fontColor: String? = nil) -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = font
        label.text = text
        label.isHidden = isHidden
        label.accessibilityTraits = accessibilityTrait

        guard let fontColor = fontColor else { return label }
        label.textColor = UIColor(named: fontColor)

        return label
    }
}
