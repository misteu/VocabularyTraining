//
//  ModalCloseButton.swift
//  VocabularyTrainer
//
//  Created by Mariana Brasil on 18/12/22.
//  Copyright © 2022 mic. All rights reserved.
//

import UIKit

final class ModalCloseButton: UIButton {

    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpButton()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setUpButton() {
        backgroundColor = UIColor(named: "closeButton")
        layer.cornerRadius = 3
        translatesAutoresizingMaskIntoConstraints = false
        accessibilityLabel = NSLocalizedString("Close", comment: "")
        accessibilityTraits = .button
    }
}
