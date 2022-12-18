//
//  UIAccessibility+Extensions.swift
//  VocabularyTrainer
//
//  Created by Mariana Brasil on 18/12/22.
//  Copyright © 2022 mic. All rights reserved.
//

import UIKit

extension UIAccessibility {
    static func focusOn(_ object: Any?) {
        if UIAccessibility.isVoiceOverRunning {
            DispatchQueue.main.asyncAfter(deadline: .now()) {
                UIAccessibility.post(notification: .layoutChanged, argument: object)
            }
        }
    }
}
