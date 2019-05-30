//
//  Helper.swift
//  VocabularyTrainer
//
//  Created by skrr on 10.03.19.
//  Copyright © 2019 mic. All rights reserved.
//

import Foundation
import UIKit

class SegueName {
  static let showNewLanguageScreenSegue = "segue"
  static let showLanguageSegue = "showLanguageSegue"
  static let showAddWordSegue = "showAddWordSegue"
  static let showTrainingSegue = "showTrainingSegue"
}

class UserDefaultKeys {
  static let languages = "languages"
}

class CellIdentifier {
  static let vocabularyCell = "vocabularyCell"
  static let languageCell = "languageCell"
}

struct BackgroundColor {
  static let blue = UIColor.init(red: 36/255, green: 110/255, blue: 185/255, alpha: 0.5)
  static let fullBlue = UIColor.init(red: 36/255, green: 110/255, blue: 185/255, alpha: 1.0)
  static let lightBlue = UIColor.init(red: 36/255, green: 110/255, blue: 185/255, alpha: 0.2)
  static let green = UIColor.init(red: 72/255, green: 175/255, blue: 64/255, alpha: 0.8)
  static let lightGreen = UIColor.init(red: 72/255, green: 175/255, blue: 64/255, alpha: 0.2)
  static let red = UIColor.init(red: 240/255, green: 101/255, blue: 67/255, alpha: 0.8)
  static let yellow = UIColor.init(red: 219/255, green: 213/255, blue: 110/255, alpha: 0.8)
  static let lightyellow = UIColor.init(red: 219/255, green: 213/255, blue: 110/255, alpha: 0.4)
  
  // rgb(211, 157, 56)
  static let gradientYellow = UIColor(red: 211/255, green: 157/255, blue: 56/255, alpha: 1.0)
  // rgb(77, 160, 176)
  static let gradientBlue = UIColor(red: 77/255, green: 160/255, blue: 176/255, alpha: 1.0)
  
  // rgb(38, 70, 83)
  static let japaneseIndigo = UIColor(red: 38/255, green: 70/255, blue: 83/255, alpha: 1.0)
  
//  rgb(233, 196, 106)
  static let hansaYellow = UIColor(red: 233/255, green: 196/255, blue: 106/255, alpha: 1.0)
  
//  rgb(214, 230, 129)
  static let mediumSpringBud = UIColor(red: 214/255, green: 230/255, blue: 129/255, alpha: 1.0)
  
  static let mediumWhite = UIColor(white: 1.0, alpha: 0.8)
}

func setGradientBackground(view: UIView) {
  let colorTop =  BackgroundColor.gradientBlue.cgColor
  let colorBottom = BackgroundColor.gradientYellow.cgColor
  
  let gradientLayer = CAGradientLayer()
  gradientLayer.colors = [colorTop, colorBottom]
  gradientLayer.locations = [0.0, 1.0]
  gradientLayer.frame = view.bounds
  
  view.layer.insertSublayer(gradientLayer, at:0)
}

