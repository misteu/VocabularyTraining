//
//  TrainingViewController.swift
//  VocabularyTrainer
//
//  Created by skrr on 12.03.19.
//  Copyright © 2019 mic. All rights reserved.
//

import UIKit

class TrainingViewController: UIViewController {
  
  var selectedLanguage: String?
  var vocabularies: [String: String]?
  var vocabulariesProgresses: [String: Float]?
  var isKeyShown: Bool?
  var currentKey: String?
    var coordinator: MainCoordinator?

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
    
    setGradientBackground(view: view)
    currentTrainingHeader.numberOfLines = 0
    currentTrainingHeader.lineBreakMode = .byWordWrapping
    currentTrainingHeader.text = """
    \(NSLocalizedString("Training:", comment: "Training:"))
    \(selectedLanguage ?? NSLocalizedString("No language selected", comment: "No language selected"))
    """
    
    styleButtons()
    pickNewVocabAndUpdateView()
    self.rightAnswerButton.isHidden = true
    self.wrongAnswerButton.isHidden = true
    
    answerInput.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
    
    hideKeyboardWhenTappedAround()
    localize()
  }
  
  func reloadVocabulariesAndProgresses() {
    guard let language = selectedLanguage else {print("no language selected"); return}
    
    guard let vocabs = UserDefaults.standard.dictionary(forKey: language) as? [String: String] else {
        print("no vocabularies found")
        return
    }
      
    guard let progresses = UserDefaults.standard.dictionary(forKey: "\(language)Progress") as? [String: Float]? else {
        print("no progresses found")
        return
    }
    
    vocabularies = vocabs
    vocabulariesProgresses = progresses
  }
  
  func getTotalProgressFrom(_ vocabulariesProgresses: [String: Float]) -> Float {
    var result = Float(0)
    
    for progress in vocabulariesProgresses {
      result += progress.value
    }
    
    return result
  }
  
  func pickRandomKeyFrom(_ vocabularies: [String: String], withProgresses vocabulariesProgresses: [String: Float], totalProgress: Float) -> String {
    let randomThreshold = Float.random(in: 0...totalProgress)
    // print(randomThreshold)
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
    
    currentKey = pickRandomKeyFrom(vocabs, withProgresses: progresses, totalProgress: totalProgress)
    
    guard let key = currentKey else {print("no key"); return}
    
    print("all vocabs \(vocabs)")
    print("all progresses \(progresses)")
    print("randomkey: \(key)")
    if (Int.random(in: 0...1) == 0) {
      currentVocabulary.text = key
      isKeyShown = true
    } else {
      currentVocabulary.text = vocabs[key]
      isKeyShown = false
    }
    nextButton.setTitle(NSLocalizedString("Skip word", comment: "Skip word"), for: .normal)
  }
  @IBAction func rightAnswerTapped(_ sender: Any) {
    guard let key = currentKey else {print("no current key"); return}
    changeWordsProbability(increase: false, key: key)
    pickNewVocabAndUpdateView()
  }
  
  @IBAction func wrongAnswerTapped(_ sender: Any) {
    guard let key = currentKey else {print("no current key"); return}
    changeWordsProbability(increase: true, key: key)
    pickNewVocabAndUpdateView()
  }
  
  @IBAction func checkInputTapped(_ sender: Any) {

    guard let usersAnswer = answerInput.text else { print("no answer given"); return }
//    guard let solution = vocabularies?[vocabulary] else {print("no solution found"); return}
    var solution: String?
    guard let isKey = isKeyShown else {print("no key"); return}
    guard let key = currentKey else {print("no current key"); return}
    guard let vocabs = vocabularies else {print("no vocabularies"); return}
    
    if isKey {
      solution = vocabs[key]
    } else {
      solution = key
    }
    
      if !usersAnswer.isEmpty {
        if usersAnswer.uppercased() == solution?.uppercased() {
        
        // update progress
        changeWordsProbability(increase: false, key: key)
        
        print("right")
        UIView.animate(withDuration: 0.2, animations: {
          self.answerInput.backgroundColor = BackgroundColor.green
          self.checkInputButton.alpha = 0.0
          self.takeALookButton.alpha = 0.0
        }, completion: { _ in
          self.checkInputButton.isHidden = true
          self.takeALookButton.isHidden = true
        })
        showToast(message: NSLocalizedString("That's right! 🤠", comment: "That's right! 🤠"), yCoord: 400.0)
        answerInput.text = solution
        nextButton.setTitle("Next word", for: .normal)
      } else {
        
        // update progress
        changeWordsProbability(increase: true, key: key)
        
        print("wrong, right is \(String(describing: solution))")
        UIView.animate(withDuration: 0.2, animations: {
          self.answerInput.backgroundColor = BackgroundColor.red
        })
        showToast(message: NSLocalizedString("That's wrong 😕", comment: "That's wrong 😕"), yCoord: 400.0)
      }
    }
  }
  
  @objc func textFieldDidChange(_ textField: UITextField) {
    resetAnswerInput()
  }
  
  @IBAction func takeALookTapped(_ sender: Any) {
    guard let key = currentKey else {print("no current key"); return}
    var solution: String
    guard let isKey = isKeyShown else {print("no key"); return}
    
    if isKey {
      solution = vocabularies?[key] ?? "nothing given"
    } else {
      solution = key
    }
    
    answerInput.text = solution
    
    UIView.animate(withDuration: 0.2, animations: {
      self.answerInput.backgroundColor = BackgroundColor.blue
      self.checkInputButton.alpha = 0.0
      self.takeALookButton.alpha = 0.0
    }, completion: { _ in
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
      self.answerInput.backgroundColor = .none
    }, completion: { _ in
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
    checkInputButton.setTitleColor(.black, for: .normal)
    
    takeALookButton.backgroundColor = BackgroundColor.blue
    takeALookButton.layer.cornerRadius = 5.0
    takeALookButton.setTitleColor(.black, for: .normal)
    
    nextButton.backgroundColor = BackgroundColor.yellow
    nextButton.layer.cornerRadius = 5.0
    nextButton.setTitleColor(.black, for: .normal)

  }
  
  func changeWordsProbability(increase: Bool, key: String) {
    guard var progresses = vocabulariesProgresses else {print("no progresses"); return}
    
    guard let key = currentKey else {print("no current key"); return}
    guard let progress = progresses[key] else {print("no progress"); return}
    
    guard let language = selectedLanguage else {print("no language selected"); return}
    
    if increase {
      progresses[key] = progress+Float(10.0)
    } else {
      if (progress-Float(3.0) > 0) {
        progresses[key] = progress-Float(3.0)
      } else {
        progresses[key] = 1.0
      }
    }
    UserDefaults.standard.set(progresses, forKey: "\(language)Progress")
    
  }
  
  func localize() {
    answerInput.placeholder = NSLocalizedString("answer", comment: "answer")
    checkInputButton.setTitle(NSLocalizedString("Check", comment: "Check"), for: .normal)
    takeALookButton.setTitle(NSLocalizedString("Take a look", comment: "Take a look"), for: .normal)
    nextButton.setTitle(NSLocalizedString("Skip word", comment: "Skip word"), for: .normal)
  
    rightAnswerButton.setTitle(NSLocalizedString("👍 I was right", comment: "👍 I was right"), for: .normal)
    wrongAnswerButton.setTitle(NSLocalizedString("👎 I was wrong", comment: "👎 I was wrong"), for: .normal)
  }
  
  // TODO: Export when pressed Backbutton or closed app (app delegate!)
}

extension TrainingViewController: StoryBoarded {}
