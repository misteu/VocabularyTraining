//
//  AddNewWordViewController.swift
//  VocabularyTrainer
//
//  Created by skrr on 11.03.19.
//  Copyright © 2019 mic. All rights reserved.
//

import UIKit

class AddNewWordViewController: UIViewController {
  
  var selectedLanguage: String?
  var vocabularies = [String:String]()
  var vocabulariesSuccessRates = [String:Float]()
  
  @IBOutlet weak var newWord: UITextField!
  @IBOutlet weak var translation: UITextField!
  @IBOutlet weak var backButton: UIButton!
  @IBOutlet weak var addButton: UIButton!
  @IBOutlet weak var addNewWordHeader: UILabel!
  override func viewDidLoad() {
    super.viewDidLoad()
    
    print("selected Language: \(String(describing: selectedLanguage))")
    hideKeyboardWhenTappedAround()
    styleButtons()
    localize()
  }
  
  @IBAction func backButtonTapped(_ sender: Any) {
    dismiss(animated: true, completion: nil)
  }
  
  @IBAction func addNewWordTapped(_ sender: Any) {
    
    guard let language = selectedLanguage else { print("error getting language"); return }
    
    let languageVocabProgressKey = "\(language)Progress"
  
    if let vocabs = UserDefaults.standard.dictionary(forKey: language) as? [String:String] {
      vocabularies = vocabs
    }
    
    if let vocabsSuccess = UserDefaults.standard.dictionary(forKey: languageVocabProgressKey) as? [String:Float] {
      vocabulariesSuccessRates = vocabsSuccess
    }
    
    if let word = newWord.text, let translatedWord = translation.text {
      vocabularies[word] = translatedWord
      vocabulariesSuccessRates[word] = 100
    }
    
    UserDefaults.standard.set(vocabularies, forKey: language)
    UserDefaults.standard.set(vocabulariesSuccessRates, forKey: languageVocabProgressKey)
    
    print( "words: \(String(describing: UserDefaults.standard.dictionary(forKey: language)))")
    //dismiss(animated: true, completion: nil)
    
    newWord.text = ""
    translation.text = ""
    
    showToast(message: NSLocalizedString("New word added", comment: "New word added"), yCoord: 340.0)
  }
  
  func styleButtons() {
    backButton.backgroundColor = BackgroundColor.blue
    backButton.layer.cornerRadius = 5.0
    backButton.contentEdgeInsets = UIEdgeInsets.init(top: 0, left: 10, bottom: 0, right: 10)
    backButton.setTitleColor(.black, for: .normal)
    
    addButton.backgroundColor = BackgroundColor.hansaYellow
    addButton.layer.cornerRadius = 5.0
    addButton.contentEdgeInsets = UIEdgeInsets.init(top: 0, left: 10, bottom: 0, right: 10)
    addButton.setTitleColor(.black, for: .normal)
  }
  
  func localize() {
    backButton.setTitle(NSLocalizedString("< Back", comment: "< Back"), for: .normal)
    addButton.setTitle(NSLocalizedString("Add", comment: "Add"), for: .normal)
    newWord.placeholder = NSLocalizedString("new word", comment: "new word")
    translation.placeholder = NSLocalizedString("translation", comment: "translation")
    addNewWordHeader.text = NSLocalizedString("Add new word", comment: "Add new word")
  }
}


