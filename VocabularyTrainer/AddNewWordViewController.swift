//
//  AddNewWordViewController.swift
//  VocabularyTrainer
//
//  Created by skrr on 11.03.19.
//  Copyright © 2019 mic. All rights reserved.
//

import UIKit
import Combine

class AddNewWordViewController: UIViewController {
  
  var selectedLanguage: String?
  var vocabularies = [String:String]()
  var vocabulariesSuccessRates = [String:Float]()
	var vocabulariesAddDates = [String:Date]()
  var completed: (()->Void)?

  @IBOutlet weak var newWordTextField: UITextField!
  @IBOutlet weak var translationTextField: UITextField!

  var newWordHasText = false
  var translationHasText = false

  @IBOutlet weak var backButton: UIButton!
  @IBOutlet weak var addButton: UIButton!
  @IBOutlet weak var addNewWordHeader: UILabel!
  override func viewDidLoad() {
    super.viewDidLoad()
    
    print("selected Language: \(String(describing: selectedLanguage))")
    hideKeyboardWhenTappedAround()
    styleButtons()
    localize()
    setGradientBackground(view: view)
    newWordTextField.text = nil
    translationTextField.text = nil
    setAddButton(isEnabled: newWordHasText && translationHasText)

    newWordTextField.addTarget(self, action: #selector(textFieldChanged(_:)), for: .editingChanged)
    translationTextField.addTarget(self, action: #selector(textFieldChanged(_:)), for: .editingChanged)
  }
  
  @IBAction func backButtonTapped(_ sender: Any) {
    completed?()
    dismiss(animated: true, completion: nil)
  }
  
  @IBAction func addNewWordTapped(_ sender: Any) {
    
    guard let language = selectedLanguage else { print("error getting language"); return }
    
    let languageVocabProgressKey = "\(language)Progress"
	let languageVocabDateAddedKey = "\(language)DateAdded"
  
    if let vocabs = UserDefaults.standard.dictionary(forKey: language) as? [String:String] {
      vocabularies = vocabs
    }
    
    if let vocabsSuccess = UserDefaults.standard.dictionary(forKey: languageVocabProgressKey) as? [String:Float] {
      vocabulariesSuccessRates = vocabsSuccess
    }

	if let vocabsDates = UserDefaults.standard.dictionary(forKey: languageVocabDateAddedKey) as? [String:Date] {
		vocabulariesAddDates = vocabsDates
	}
    
    if let word = newWordTextField.text, let translatedWord = translationTextField.text {
      vocabularies[word] = translatedWord
      vocabulariesSuccessRates[word] = 100
		vocabulariesAddDates[word] = Date()
    }
    
    UserDefaults.standard.set(vocabularies, forKey: language)
    UserDefaults.standard.set(vocabulariesSuccessRates, forKey: languageVocabProgressKey)
	UserDefaults.standard.set(vocabulariesAddDates, forKey: languageVocabDateAddedKey)
    
    print( "words: \(String(describing: UserDefaults.standard.dictionary(forKey: language)))")
    //dismiss(animated: true, completion: nil)
    
    newWordTextField.text = ""
    translationTextField.text = ""
    newWordHasText = false
    translationHasText = false
    setAddButton(isEnabled: false)
    showToast(message: NSLocalizedString("New word added", comment: "New word added"), yCoord: 340.0)
  }
  
  func styleButtons() {
    backButton.backgroundColor = BackgroundColor.hansaYellow
    backButton.layer.cornerRadius = 5.0
    backButton.contentEdgeInsets = UIEdgeInsets.init(top: 0, left: 10, bottom: 0, right: 10)
    backButton.setTitleColor(BackgroundColor.japaneseIndigo, for: .normal)

    setAddButton(isEnabled: true)
  }
  
  func localize() {
    backButton.setTitle(NSLocalizedString("< Back", comment: "< Back"), for: .normal)
    addButton.setTitle(NSLocalizedString("Add", comment: "Add"), for: .normal)
    newWordTextField.placeholder = NSLocalizedString("New word", comment: "new word")
    translationTextField.placeholder = NSLocalizedString("translation", comment: "translation")
    addNewWordHeader.text = NSLocalizedString("Add new word", comment: "Add new word")
  }

  func setAddButton(isEnabled: Bool) {
    if isEnabled {
      UIView.animate(withDuration: 0.3) {
        self.addButton.backgroundColor = BackgroundColor.mediumSpringBud
      }
      addButton.layer.cornerRadius = 5.0
      addButton.contentEdgeInsets = UIEdgeInsets.init(top: 0, left: 10, bottom: 0, right: 10)
      addButton.setTitleColor(.black, for: .normal)
      addButton.isEnabled = true
    } else {
      UIView.animate(withDuration: 0.3) {
        self.addButton.backgroundColor = UIColor(red: 207/255, green: 207/255, blue: 205/255, alpha: 0.4)
      }
      addButton.layer.cornerRadius = 5.0
      addButton.contentEdgeInsets = UIEdgeInsets.init(top: 0, left: 10, bottom: 0, right: 10)
      addButton.setTitleColor(.black, for: .normal)
      addButton.isEnabled = false
    }
  }

  @objc func textFieldChanged(_ sender: UITextField) {
    let hasText = !(sender.text == nil || sender.text == "")
    if sender === newWordTextField {
      newWordHasText = hasText
    }

    if sender === translationTextField {
      translationHasText = hasText
    }
    setAddButton(isEnabled: newWordHasText && translationHasText)
  }
}
