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
  @IBOutlet weak var nextButton: UIButton!
  @IBOutlet weak var currentTrainingHeader: UILabel!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    currentTrainingHeader.numberOfLines = 0;
    currentTrainingHeader.lineBreakMode = .byWordWrapping
    currentTrainingHeader.text = """
    Training:
    \(selectedLanguage ?? "no language selected")
    """
    
    styleButtons()
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
    nextButton.setTitle("Skip word", for: .normal)
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
          self.answerInput.backgroundColor = BackgroundColor.green
          self.checkInputButton.alpha = 0.0
          self.takeALookButton.alpha = 0.0
        }, completion: { (finished: Bool) in
          self.checkInputButton.isHidden = true
          self.takeALookButton.isHidden = true
        })
        showToast(message: "That's right! 🤠", yCoord: 400.0)
        nextButton.setTitle("Next word", for: .normal)
      } else {
        print("wrong, right is \(solution)")
        UIView.animate(withDuration: 0.2, animations: {
          self.answerInput.backgroundColor = BackgroundColor.red
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
      self.answerInput.backgroundColor = BackgroundColor.blue
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
    
    UIView.animate(withDuration: 0.2, animations: {
      self.rightAnswerButton.alpha = 0.0
      self.wrongAnswerButton.alpha = 0.0
      self.answerInput.backgroundColor = .white
    }, completion: { (finished: Bool) in
      self.rightAnswerButton.isHidden = true
      self.wrongAnswerButton.isHidden = true
      self.checkInputButton.isHidden = false
      self.takeALookButton.isHidden = false
      
      UIView.animate(withDuration: 0.1, animations: {
        self.checkInputButton.alpha = 1.0
        self.takeALookButton.alpha = 1.0
        self.view.layoutIfNeeded()
      })
    })
    
  }
  
  func styleButtons() {
    rightAnswerButton.backgroundColor = BackgroundColor.green
    rightAnswerButton.layer.cornerRadius = 5.0
    
    wrongAnswerButton.backgroundColor = BackgroundColor.red
    wrongAnswerButton.layer.cornerRadius = 5.0
    
    checkInputButton.backgroundColor = BackgroundColor.blue
    checkInputButton.layer.cornerRadius = 5.0
    checkInputButton.setTitleColor(.white, for: .normal)
    
    takeALookButton.backgroundColor = BackgroundColor.blue
    takeALookButton.layer.cornerRadius = 5.0
    takeALookButton.setTitleColor(.white, for: .normal)
    
    nextButton.backgroundColor = BackgroundColor.yellow
    nextButton.layer.cornerRadius = 5.0
    nextButton.setTitleColor(.white, for: .normal)
    
  }
}
