//
//  NewLanguageViewController.swift
//  VocabularyTrainer
//
//  Created by skrr on 10.03.19.
//  Copyright © 2019 mic. All rights reserved.
//

import UIKit
class NewLanguageViewController: UIViewController {
  
  var delegate: NewLanguageScreenProtocol?

  init(delegate: NewLanguageScreenProtocol?) {
    self.delegate = delegate
    super.init(nibName: nil, bundle: nil)
  }

  required init?(coder: NSCoder) { nil }

  // Back Button
  var goBackButton: UIButton = {
    let button = UIButton(frame: .zero)
    
    button.setTitle(NSLocalizedString("< Back", comment: "< Back"), for: .normal)
    button.setTitleColor(.black, for: .normal)
    
    button.backgroundColor = BackgroundColor.blue
    button.layer.cornerRadius = 5.0
    return button
  }()
  
  // New Language Header
  var newLanguageHeader: UILabel = {
    let label = UILabel(frame: .zero)
    label.text = NSLocalizedString("Add new language", comment: "Add new language")
    label.font = .preferredFont(forTextStyle: .title1)
    return label
  }()
  
  // New Language Text Field
  var newLanguage: UITextField = {
    let field = UITextField(frame: .zero)
    field.placeholder = NSLocalizedString("which language?", comment: "which language?")
    field.font = .preferredFont(forTextStyle: .largeTitle)
    field.backgroundColor = .systemBackground
    field.layer.cornerRadius = 5
    return field
  }()
  
  // Add Button
  var addButton: UIButton = {
    let addButton = UIButton(frame: .zero)
    addButton.backgroundColor = BackgroundColor.green
    addButton.layer.cornerRadius = 5.0
    addButton.contentEdgeInsets = UIEdgeInsets.init(top: 0, left: 10, bottom: 0, right: 10)
    addButton.setTitleColor(.black, for: .normal)
    // addButton.setTitle(NSLocalizedString("Add language", comment: "Add language"), for: .normal)
    addButton.setTitle(NSLocalizedString("Add", comment: "Add"), for: .normal)
    addButton.titleLabel?.font = .preferredFont(forTextStyle: .title2)
    return addButton
  }()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    hideKeyboardWhenTappedAround()
    setGradientBackground(view: view)
    
    setup()
    layout()
  }
}

// MARK: - Layout & Programmatic UI
extension NewLanguageViewController {
  
  private func setup() {
    self.view.addSubview(goBackButton)
    self.goBackButton.translatesAutoresizingMaskIntoConstraints = false
    self.goBackButton.addTarget(self, action: #selector(backButtonAction), for: .touchUpInside)

    self.view.addSubview(newLanguageHeader)
    self.newLanguageHeader.translatesAutoresizingMaskIntoConstraints = false
    
    self.view.addSubview(newLanguage)
    self.newLanguage.translatesAutoresizingMaskIntoConstraints = false
    
    self.view.addSubview(addButton)
    self.addButton.translatesAutoresizingMaskIntoConstraints = false
    self.addButton.addTarget(self, action: #selector(addLanguageAction), for: .touchUpInside)
  }
  
  private func layout() {
    backButtonLayout()
    newLanguageHeaderLayout()
    fieldLayout()
    
    addLanguageLayout()
  }
  
  private func backButtonLayout() {
    NSLayoutConstraint.activate([
      goBackButton.leadingAnchor.constraint(equalToSystemSpacingAfter: self.view.leadingAnchor, multiplier: 2.5),
      goBackButton.topAnchor.constraint(equalToSystemSpacingBelow: self.view.topAnchor, multiplier: 2.5),
      goBackButton.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.2),
      goBackButton.heightAnchor.constraint(equalTo: self.view.heightAnchor, multiplier: 0.05)
    ])
  }
  
  private func newLanguageHeaderLayout() {
    NSLayoutConstraint.activate([
      self.newLanguageHeader.topAnchor.constraint(equalToSystemSpacingBelow: goBackButton.bottomAnchor, multiplier: 2.5),
      self.newLanguageHeader.centerXAnchor.constraint(equalTo: self.view.centerXAnchor)
    ])
  }
  
  private func fieldLayout() {
    NSLayoutConstraint.activate([
      self.newLanguage.topAnchor.constraint(equalToSystemSpacingBelow: newLanguageHeader.bottomAnchor, multiplier: 4),
      self.newLanguage.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
      self.newLanguage.widthAnchor.constraint(equalToConstant: 339),
      self.newLanguage.heightAnchor.constraint(equalToConstant: 48)
    ])
  }
  
  private func addLanguageLayout() {
    NSLayoutConstraint.activate([
      self.addButton.topAnchor.constraint(equalToSystemSpacingBelow: newLanguage.bottomAnchor, multiplier: 4),
      self.addButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
      self.addButton.widthAnchor.constraint(equalToConstant: 350),
      self.addButton.heightAnchor.constraint(equalToConstant: 42)
    ])
  }
}

// Button Actions
extension NewLanguageViewController {
  // Back Button Action
  @objc func backButtonAction() {
    dismiss(animated: true, completion: nil)
  }

  // Add Language Action
  @objc func addLanguageAction() {
      if let delegate = self.delegate, let newLanguage = newLanguage.text, !newLanguage.isEmpty {
      
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
}

extension UIView {
  
  func applyGradient(colours: [UIColor]) -> CAGradientLayer {
    return self.applyGradient(colours: colours, locations: nil)
  }

  func applyGradient(colours: [UIColor], locations: [NSNumber]?) -> CAGradientLayer {
    let gradient: CAGradientLayer = CAGradientLayer()
    gradient.frame = self.bounds
    gradient.colors = colours.map { $0.cgColor }
    gradient.locations = locations
    self.layer.insertSublayer(gradient, at: 0)
    return gradient
  }
}
