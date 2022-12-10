//
//  TrainingViewController.swift
//  VocabularyTrainer
//
//  Created by skrr on 12.03.19.
//  Copyright © 2019 mic. All rights reserved.
//

import UIKit

class TrainingViewController: UIViewController {
  
  private let selectedLanguage: String
  var vocabularies: [String: String]?
  var vocabulariesProgresses: [String: Float]?
  var isKeyShown: Bool?
  var currentKey: String?
    var coordinator: MainCoordinator?

  var wrongAnswerButton = UIButton()
  var rightAnswerButton = UIButton()
  var nextButton = UIButton()
  var checkInputButton = UIButton()
  var takeALookButton = UIButton()

  var currentVocabulary = UILabel()
  var answerInput = UITextField()
  var currentTrainingHeader = UILabel()

  let checkLookStackView = UIStackView()
  let rightWrongStackView = UIStackView()

  let defaultInputBackground = UIColor.systemBackground.withAlphaComponent(0.5)

  // MARK: - Init

  init(with language: String) {
    self.selectedLanguage = language
    super.init(nibName: nil, bundle: nil)
    setButtonActions()
    setViewHierarchy()
    setConstraints()
  }

  required init?(coder: NSCoder) { nil }

  private func setButtonActions() {
    wrongAnswerButton.addTarget(self, action: #selector(wrongAnswerTapped(_:)), for: .touchUpInside)
    rightAnswerButton.addTarget(self, action: #selector(rightAnswerTapped(_:)), for: .touchUpInside)
    nextButton.addTarget(self, action: #selector(nextButtonTapped(_:)), for: .touchUpInside)
    checkInputButton.addTarget(self, action: #selector(checkInputTapped(_:)), for: .touchUpInside)
    takeALookButton.addTarget(self, action: #selector(takeALookTapped(_:)), for: .touchUpInside)
  }

  private func setViewHierarchy() {

    let rightWrongButtons = [wrongAnswerButton, rightAnswerButton]
    let checkTakeLookButtons = [checkInputButton, takeALookButton]

    rightWrongButtons.forEach { rightWrongStackView.addArrangedSubview($0) }
    checkTakeLookButtons.forEach { checkLookStackView.addArrangedSubview($0) }
    rightWrongStackView.distribution = .fillEqually
    rightWrongStackView.spacing = 16
    checkLookStackView.distribution = .fillEqually
    checkLookStackView.spacing = 16

    [
      currentTrainingHeader,
      currentVocabulary,
      answerInput,
      checkLookStackView,
      rightWrongStackView,
      nextButton
    ].forEach { view.addSubview($0) }
  }

  private func setConstraints() {
    [
      // inside rightWrongStackView
      wrongAnswerButton, rightAnswerButton,
      // inside checkLookStackView
      checkInputButton, takeALookButton,

      currentTrainingHeader,
      currentVocabulary,
      answerInput,
      checkLookStackView,
      rightWrongStackView,
      nextButton
    ].forEach { $0.translatesAutoresizingMaskIntoConstraints = false }

    NSLayoutConstraint.activate([
      currentTrainingHeader.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor),
      currentTrainingHeader.centerXAnchor.constraint(equalTo: view.centerXAnchor),

      currentVocabulary.topAnchor.constraint(equalTo: currentTrainingHeader.bottomAnchor, constant: 16),
      currentVocabulary.centerXAnchor.constraint(equalTo: view.centerXAnchor),

      answerInput.topAnchor.constraint(equalTo: currentVocabulary.bottomAnchor, constant: 16),
      answerInput.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor, constant: 16),
      answerInput.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor, constant: -16),

      checkLookStackView.topAnchor.constraint(equalTo: answerInput.bottomAnchor, constant: 16),
      checkLookStackView.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor, constant: 16),
      checkLookStackView.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor, constant: -16),

      rightWrongStackView.topAnchor.constraint(equalTo: answerInput.bottomAnchor, constant: 16),
      rightWrongStackView.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor, constant: 16),
      rightWrongStackView.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor, constant: -16),

      nextButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -32),
      nextButton.heightAnchor.constraint(greaterThanOrEqualToConstant: 44),
      nextButton.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor, constant: 16),
      nextButton.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor, constant: -16),

      wrongAnswerButton.heightAnchor.constraint(greaterThanOrEqualToConstant: Layout.defaultButtonHeight),
      rightAnswerButton.heightAnchor.constraint(greaterThanOrEqualToConstant: Layout.defaultButtonHeight),
      checkInputButton.heightAnchor.constraint(greaterThanOrEqualToConstant: Layout.defaultButtonHeight),
      takeALookButton.heightAnchor.constraint(greaterThanOrEqualToConstant: Layout.defaultButtonHeight)
    ])

  }

  override func viewDidLoad() {
    super.viewDidLoad()
    setup()
  }

  private func setup() {

    currentVocabulary.font = .preferredFont(forTextStyle: .title1)
    setGradientBackground(view: view)
    currentTrainingHeader.numberOfLines = 0
    currentTrainingHeader.lineBreakMode = .byWordWrapping
    currentTrainingHeader.text = """
    \(NSLocalizedString("Training:", comment: "Training:"))
    \(selectedLanguage)
    """
    
    styleButtons()
    pickNewVocabAndUpdateView()
    self.rightAnswerButton.isHidden = true
    self.wrongAnswerButton.isHidden = true
    
    answerInput.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
    answerInput.backgroundColor = defaultInputBackground
    answerInput.font = UIFont.preferredFont(forTextStyle: .title1)

    hideKeyboardWhenTappedAround()
    localize()
  }
  
  func reloadVocabulariesAndProgresses() {
    let language = selectedLanguage

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

  @objc func nextButtonTapped(_ sender: Any) {
    pickNewVocabAndUpdateView()
  }

  @objc func rightAnswerTapped(_ sender: Any) {
    guard let key = currentKey else {print("no current key"); return}
    changeWordsProbability(increase: false, key: key)
    pickNewVocabAndUpdateView()
  }
  
  @objc func wrongAnswerTapped(_ sender: Any) {
    guard let key = currentKey else {print("no current key"); return}
    changeWordsProbability(increase: true, key: key)
    pickNewVocabAndUpdateView()
  }
  
  @objc func checkInputTapped(_ sender: Any) {

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

  @objc func takeALookTapped(_ sender: Any) {
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

  @objc func textFieldDidChange(_ textField: UITextField) {
    resetAnswerInput()
  }

  func resetAnswerInput() {
    
    UIView.animate(withDuration: 0.2, animations: {
      self.rightAnswerButton.alpha = 0.0
      self.wrongAnswerButton.alpha = 0.0
      self.answerInput.backgroundColor = self.defaultInputBackground
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
    
    let language = selectedLanguage

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
