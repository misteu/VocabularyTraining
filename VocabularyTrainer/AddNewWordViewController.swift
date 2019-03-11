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
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    print("selected Language: \(String(describing: selectedLanguage))")
    // Do any additional setup after loading the view.
    
    
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
    
    print( "words: \(UserDefaults.standard.dictionary(forKey: language))")
    dismiss(animated: true, completion: nil)
  }
}
