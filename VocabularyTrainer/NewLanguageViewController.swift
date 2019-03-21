//
//  NewLanguageViewController.swift
//  VocabularyTrainer
//
//  Created by skrr on 10.03.19.
//  Copyright © 2019 mic. All rights reserved.
//

import UIKit

protocol NewLanguageScreenProtocol {
  func setNewLanguage(language: String)
}

class NewLanguageViewController: UIViewController {
  
  var delegate: NewLanguageScreenProtocol? = nil
  
  @IBOutlet weak var newLanguage: UITextField!
  override func viewDidLoad() {
    super.viewDidLoad()
    hideKeyboardWhenTappedAround()
    // Do any additional setup after loading the view.
  }
  
  @IBAction func addLanguageTapped(_ sender: Any) {
    
    if let delegate = self.delegate, let newLanguage = newLanguage.text {
      delegate.setNewLanguage(language: newLanguage)
      
      if let savedLanguages = UserDefaults.standard.array(forKey: UserDefaultKeys.languages) as? [String] {
        var languages = savedLanguages
        languages.append(newLanguage)
        UserDefaults.standard.set(languages, forKey: UserDefaultKeys.languages)
      } else {
        UserDefaults.standard.set([newLanguage], forKey: UserDefaultKeys.languages)
      }
      
      dismiss(animated: true, completion: nil)
    }
    
  }
  @IBAction func backButtonTapped(_ sender: Any) {
    dismiss(animated: true, completion: nil)
  }
}
