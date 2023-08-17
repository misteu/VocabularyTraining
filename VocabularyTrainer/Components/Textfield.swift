//
//  Textfield.swift
//  VocabularyTrainer
//
//  Created by Michael Steudter on 12.02.23.
//  Copyright © 2023 mic. All rights reserved.
//

import UIKit

class TextField: UITextField {

    static let defaultPadding = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
    static let defaultBackground = UIColor.systemBackground.withAlphaComponent(0.5)
    static let defaultFont = UIFont.preferredFont(forTextStyle: .title1)

    // MARK: - Init

    init(placeholder: String? = nil) {
        super.init(frame: .zero)
        setup()
    }

    private func setup() {
        placeholder = placeholder
        backgroundColor = Self.defaultBackground
        font = Self.defaultFont
        layer.cornerRadius = 4
        layer.cornerCurve = .continuous
        autocapitalizationType = .none
        autocorrectionType = .no
        translatesAutoresizingMaskIntoConstraints = false
    }

    required init?(coder: NSCoder) { nil }

    // MARK: - Internal Methods

    override open func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: Self.defaultPadding)
    }

    override open func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: Self.defaultPadding)
    }

    override open func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: Self.defaultPadding)
    }
}
