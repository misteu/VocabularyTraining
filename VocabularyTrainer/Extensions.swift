//
//  Extensions.swift
//  VocabularyTrainer
//
//  Created by skrr on 21.03.19.
//  Copyright © 2019 mic. All rights reserved.
//

import Foundation
import UIKit


extension UIViewController {
  
  func hideKeyboardWhenTappedAround() {
    let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
    tap.cancelsTouchesInView = false
    view.addGestureRecognizer(tap)
  }
  
  @objc func dismissKeyboard() {
    view.endEditing(true)
  }
}
