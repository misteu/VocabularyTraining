//
//  NewLanguageViewController.swift
//  VocabularyTrainer
//
//  Created by skrr on 10.03.19.
//  Copyright © 2019 mic. All rights reserved.
//

import UIKit

class NewLanguageViewController: UIViewController {
  
  var delegate: NewLanguageScreenProtocol? = nil
  
  @IBOutlet weak var backButton: UIButton!
  @IBOutlet weak var addButton: UIButton!
  @IBOutlet weak var newLanguage: UITextField!
  @IBOutlet weak var newLanguageHeader: UILabel!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    hideKeyboardWhenTappedAround()
    // Do any additional setup after loading the view.
    styleButtons()
    localize()
    setGradientBackground(view: view)
  }
  
  @IBAction func addLanguageTapped(_ sender: Any) {
    
    if let delegate = self.delegate, let newLanguage = newLanguage.text {
      
      if let savedLanguages = UserDefaults.standard.array(forKey: UserDefaultKeys.languages) as? [String] {
        var languages = savedLanguages
        languages.append(newLanguage)
        UserDefaults.standard.set(languages, forKey: UserDefaultKeys.languages)
      } else {
        UserDefaults.standard.set([newLanguage], forKey: UserDefaultKeys.languages)
      }
      delegate.updateLanguageTable(language: newLanguage)
      dismiss(animated: true, completion: nil)
    }
    
  }
  @IBAction func backButtonTapped(_ sender: Any) {
    dismiss(animated: true, completion: nil)
  }
  
  func styleButtons() {
    backButton.backgroundColor = BackgroundColor.blue
    backButton.layer.cornerRadius = 5.0
    backButton.contentEdgeInsets = UIEdgeInsets.init(top: 0, left: 10, bottom: 0, right: 10)
    backButton.setTitleColor(.black, for: .normal)
    
    addButton.backgroundColor = BackgroundColor.green
    addButton.layer.cornerRadius = 5.0
    addButton.contentEdgeInsets = UIEdgeInsets.init(top: 0, left: 10, bottom: 0, right: 10)
    addButton.setTitleColor(.black, for: .normal)
    addButton.setTitle(NSLocalizedString("Add language", comment: "Add language"), for: .normal)
  }
  
  func localize() {
    newLanguage.placeholder = NSLocalizedString("which language?", comment: "which language?")
    addButton.setTitle(NSLocalizedString("Add", comment: "Add"), for: .normal)
    backButton.setTitle(NSLocalizedString("< Back", comment: "< Back"), for: .normal)
    newLanguageHeader.text = NSLocalizedString("Add new language", comment: "Add new language")
  }
}
