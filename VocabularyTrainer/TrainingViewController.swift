//
//  TrainingViewController.swift
//  VocabularyTrainer
//
//  Created by skrr on 12.03.19.
//  Copyright © 2019 mic. All rights reserved.
//

import UIKit

class TrainingViewController: UIViewController {
  
  var selectedLanguage: String? = nil
  var vocabularies: [String:String]? = nil
  var vocabulariesProgresses: [String:Float]? = nil

  @IBOutlet weak var wrongAnswerButton: UIButton!
  @IBOutlet weak var rightAnswerButton: UIButton!
  @IBOutlet weak var currentVocabulary: UILabel!
  @IBOutlet weak var answerInput: UITextField!
  @IBOutlet weak var checkInputButton: UIButton!
  @IBOutlet weak var takeALookButton: UIButton!
  @IBOutlet weak var currentTrainingHeader: UILabel!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    currentTrainingHeader.numberOfLines = 0;
    currentTrainingHeader.lineBreakMode = .byWordWrapping
    currentTrainingHeader.text = """
    Training:
    \(selectedLanguage ?? "no language selected")
    """
    
    styleRightWrongButtons()
    pickNewVocabAndUpdateView()
    self.rightAnswerButton.isHidden = true
    self.wrongAnswerButton.isHidden = true
    
    answerInput.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
    
    hideKeyboardWhenTappedAround()
  }
  
  func reloadVocabulariesAndProgresses() {
    guard let language = selectedLanguage else {print("no language selected"); return}
    
    guard let vocabs = UserDefaults.standard.dictionary(forKey: language) as? [String:String] else { print("no vocabularies found"); return}
    guard let progresses = UserDefaults.standard.dictionary(forKey: "\(language)Progress") as? [String:Float]? else { print("no progresses found"); return}
    
    vocabularies = vocabs
    vocabulariesProgresses = progresses
  }
  
  func getTotalProgressFrom(_ vocabulariesProgresses: [String:Float])->Float {
    var result = Float(0)
    
    for progress in vocabulariesProgresses {
      result += progress.value
    }
    
    return result
  }
  
  func pickRandomKeyFrom(_ vocabularies: [String:String], withProgresses vocabulariesProgresses: [String:Float], totalProgress:Float)->String {
    let randomThreshold = Float.random(in: 0...totalProgress)
    //print(randomThreshold)
    var summedUpProgresses = Float(0)
    var resultKey = ""
    
    for (key, value) in vocabulariesProgresses {
      summedUpProgresses += value
      if summedUpProgresses > randomThreshold {
        resultKey = key
        print("key's progress: \(value)")
        break
      }
    }
    return resultKey
  }
  @IBAction func backButtonTapped(_ sender: Any) {
    dismiss(animated: true, completion: nil)
  }
  @IBAction func nextButtonTapped(_ sender: Any) {
    pickNewVocabAndUpdateView()
  }
  
  func pickNewVocabAndUpdateView() {
    
    resetAnswerInput()
    answerInput.text = ""
    
    reloadVocabulariesAndProgresses()
    guard let vocabs = vocabularies else {print("no vocabularies"); return}
    guard let progresses = vocabulariesProgresses else {print("no progresses"); return }
    
    let totalProgress = getTotalProgressFrom(progresses)
    
    let randomKey = pickRandomKeyFrom(vocabs, withProgresses: progresses, totalProgress: totalProgress)
    
    print("randomkey: \(randomKey)")
    currentVocabulary.text = randomKey
  }
  @IBAction func rightAnswerTapped(_ sender: Any) {
    
    guard var progresses = vocabulariesProgresses else {print("no progresses"); return}
    guard let vocabulary = currentVocabulary.text else {print("no vocab"); return}
    
    guard let language = selectedLanguage else {print("no language selected"); return}
    guard let progress = progresses[vocabulary] else {print("no progress"); return}
    progresses[vocabulary] = progress-Float(3.0)
    UserDefaults.standard.set(progresses, forKey: "\(language)Progress")
    
    pickNewVocabAndUpdateView()
  }
  @IBAction func wrongAnswerTapped(_ sender: Any) {
    
    guard var progresses = vocabulariesProgresses else {print("no progresses"); return}
    guard let vocabulary = currentVocabulary.text else {print("no vocab"); return}
    
    guard let language = selectedLanguage else {print("no language selected"); return}
    guard let progress = progresses[vocabulary] else {print("no progress"); return}
    progresses[vocabulary] = progress+Float(10.0)
    UserDefaults.standard.set(progresses, forKey: "\(language)Progress")
    
    pickNewVocabAndUpdateView()
  }
  
  @IBAction func checkInputTapped(_ sender: Any) {
    guard let vocabulary = currentVocabulary.text else {print("no vocab"); return}
    guard let usersAnswer = answerInput.text else { print("no answer given"); return }
    guard let solution = vocabularies?[vocabulary] else {print("no solution found"); return}
    
    if usersAnswer != "" {
      if usersAnswer.uppercased() == solution.uppercased() {
        print("right")
        UIView.animate(withDuration: 0.2, animations: {
          self.answerInput.backgroundColor = .init(red: 72/255, green: 175/255, blue: 64/255, alpha: 0.5)
          self.checkInputButton.alpha = 0.0
          self.takeALookButton.alpha = 0.0
        }, completion: { (finished: Bool) in
          self.checkInputButton.isHidden = true
          self.takeALookButton.isHidden = true
        })
        showToast(message: "That's right! 🤠", yCoord: 400.0)
      } else {
        print("wrong, right is \(solution)")
        UIView.animate(withDuration: 0.2, animations: {
          self.answerInput.backgroundColor = .init(red: 240/255, green: 101/255, blue: 67/255, alpha: 0.5)
        })
        showToast(message: "That's wrong 😕", yCoord: 400.0)
      }
    }
  }
  
  @objc func textFieldDidChange(_ textField: UITextField) {
    resetAnswerInput()
  }
  
  @IBAction func takeALookTapped(_ sender: Any) {
    guard let vocabulary = currentVocabulary.text else {print("no vocab"); return}
    guard let solution = vocabularies?[vocabulary] else {print("no solution found"); return}
    
    answerInput.text = solution
    
    UIView.animate(withDuration: 0.2, animations: {
      self.answerInput.backgroundColor = .init(red: 36/255, green: 110/255, blue: 185/255, alpha: 0.5)
      self.checkInputButton.alpha = 0.0
      self.takeALookButton.alpha = 0.0
    }, completion: { (finished: Bool) in
      self.rightAnswerButton.isHidden = false
      self.wrongAnswerButton.isHidden = false
      self.checkInputButton.isHidden = true
      self.takeALookButton.isHidden = true
      
      UIView.animate(withDuration: 0.2, animations: {
        self.view.layoutIfNeeded()
        self.rightAnswerButton.alpha = 1.0
        self.wrongAnswerButton.alpha = 1.0
      })

    })
  }
  
  func resetAnswerInput() {
    
    checkInputButton.isHidden = false
    takeALookButton.isHidden = false
    UIView.animate(withDuration: 0.2, animations: {
      self.rightAnswerButton.alpha = 0.0
      self.wrongAnswerButton.alpha = 0.0
      self.answerInput.backgroundColor = .white
      self.checkInputButton.alpha = 1.0
      self.takeALookButton.alpha = 1.0
    }, completion: { (finished: Bool) in
      self.rightAnswerButton.isHidden = true
      self.wrongAnswerButton.isHidden = true
      UIView.animate(withDuration: 0.2, animations: {
        self.view.layoutIfNeeded()
      })
    })
    
  }
  
  func styleRightWrongButtons() {
    rightAnswerButton.backgroundColor = .init(red: 72/255, green: 175/255, blue: 64/255, alpha: 0.5)
    rightAnswerButton.layer.cornerRadius = 5.0
    
    wrongAnswerButton.backgroundColor = .init(red: 240/255, green: 101/255, blue: 67/255, alpha: 0.5)
    wrongAnswerButton.layer.cornerRadius = 5.0
  }
}
