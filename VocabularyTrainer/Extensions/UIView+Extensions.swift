//
//  UIView+Extensions.swift
//  VocabularyTrainer
//
//  Created by Mariana Brasil on 18/12/22.
//  Copyright © 2022 mic. All rights reserved.
//

import UIKit

extension UIView {
    func addSubviews(_ subviews: [UIView]) {
        subviews.forEach {
            addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
    }

    func shake(duration: TimeInterval = 0.5, xValue: CGFloat = 12, yValue: CGFloat = 0) {
        self.transform = CGAffineTransform(translationX: xValue, y: yValue)
        UIView.animate(withDuration: duration,
                       delay: 0,
                       usingSpringWithDamping: 0.4,
                       initialSpringVelocity: 1.0,
                       options: .curveEaseInOut,
                       animations: { [weak self] in
            self?.transform = CGAffineTransform.identity
        },
                       completion: nil)
    }
}
