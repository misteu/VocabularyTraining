//
//  UILabel+Extensions.swift
//  VocabularyTrainer
//
//  Created by Mariana Brasil on 16/12/22.
//  Copyright © 2022 mic. All rights reserved.
//

import UIKit

protocol ColorSpec {}
extension UIColor: ColorSpec {}
extension String: ColorSpec {}

extension UILabel {
    static func createLabel(font: UIFont? = .preferredFont(forTextStyle: .body),
                            text: String = "",
                            isHidden: Bool = false,
                            accessibilityTrait: UIAccessibilityTraits = .staticText,
                            fontColor: ColorSpec? = nil,
                            numberOfLines: Int = 0,
                            textAlignment: NSTextAlignment = .natural) -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = font
        label.text = text
        label.isHidden = isHidden
        label.accessibilityTraits = accessibilityTrait
        label.numberOfLines = numberOfLines
        label.lineBreakMode = .byWordWrapping
        label.textAlignment = textAlignment

        guard let fontColor = fontColor else { return label }
        switch fontColor {
        case let color as UIColor:
            label.textColor = color
        case let colorName as String:
            label.textColor = UIColor(named: colorName)
        default:
            break
        }

        return label
    }
}
