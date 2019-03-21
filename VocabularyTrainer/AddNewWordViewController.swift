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
    
    hideKeyboardWhenTappedAround()
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
    //dismiss(animated: true, completion: nil)
    
    newWord.text = ""
    translation.text = ""
    
    showToast(message: "New word added", yCoord: 340.0)
  }
}

extension UIViewController {
  
  func showToast(message : String, yCoord: CGFloat) {
    //self.view.frame.size.height-100
    
    let toastLabel = UILabel(frame: CGRect(x: self.view.frame.size.width/2 - 125, y: yCoord , width: 250, height: 35))
    toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.6)
    toastLabel.textColor = UIColor.white
    toastLabel.textAlignment = .center;
    toastLabel.font = UIFont.systemFont(ofSize: 24.0)
    toastLabel.text = message
    toastLabel.alpha = 1.0
    toastLabel.layer.cornerRadius = 10;
    toastLabel.clipsToBounds  =  true
    self.view.addSubview(toastLabel)
    UIView.animate(withDuration: 4.0, delay: 0.1, options: .curveEaseOut, animations: {
      toastLabel.alpha = 0.0
    }, completion: {(isCompleted) in
      toastLabel.removeFromSuperview()
    })
  } }


