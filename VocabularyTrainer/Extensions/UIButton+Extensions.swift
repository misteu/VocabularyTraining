//
//  UIButton+Extensions.swift
//  VocabularyTrainer
//
//  Created by Michael Steudter on 02.01.23.
//  Copyright © 2023 mic. All rights reserved.
//

import UIKit

extension UIButton {

    enum IconType {
        case importButton
        case exportButton

        /// Trailing image of the icon button.
        var image: UIImage? {
            switch self {
            case .importButton:
                return UIImage(systemName: "square.and.arrow.down")
            case .exportButton:
                return UIImage(systemName: "square.and.arrow.up")
            }
        }
        /// Text for icon button.
        var text: String {
            switch self {
            case .importButton:
                return HomeViewModel.Strings.importButtonTitle
            case .exportButton:
                return HomeViewModel.Strings.exportButtonTitle
            }
        }
    }

    /// Creates and returns button with trailing image.
    /// - Parameters:
    ///   - text: The text to show.
    ///   - image: The trailing image shown next to the text.
    ///   - tapHandler: The block, executed when tapping the button.
    static func iconButton(text: String, trailingImage image: UIImage?, tapHandler: (() -> Void)?) -> UIButton {
        let label = UILabel()
        let text = NSMutableAttributedString(string: text)
        guard let image = image else { return UIButton() }
        let attachment = NSTextAttachment(image: image)
        let padding = NSTextAttachment()
        padding.bounds = .init(origin: .zero, size: .init(width: 4, height: 0))
        text.append(.init(attachment: padding))
        text.append(.init(attachment: attachment))
        label.attributedText = text
        let button = UIButton(
            type: .system,
            primaryAction: .init(handler: { _ in
                tapHandler?()
            }))
        button.setAttributedTitle(text, for: .normal)
        button.setTitleColor(.label, for: .normal)
        return button
    }

    /// Creates and returns icon button for given type.
    /// - Parameters:
    ///   - type: The type of icon button.
    ///   - tapHandler: The block executed when tapping the button.
    static func iconButton(type: IconType, tapHandler: (() -> Void)?) -> UIButton {
        iconButton(text: type.text, trailingImage: type.image, tapHandler: tapHandler)
    }
}
