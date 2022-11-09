//
//  NewLanguageViewController.swift
//  VocabularyTrainer
//
//  Created by skrr on 10.03.19.
//  Copyright © 2019 mic. All rights reserved.
//

import UIKit
class NewLanguageViewController: UIViewController {
  
  weak var delegate: NewLanguageScreenProtocol?
  var coordinator: MainCoordinator?
    
  init(delegate: NewLanguageScreenProtocol?) {
    self.delegate = delegate
    super.init(nibName: nil, bundle: nil)
  }

  required init?(coder: NSCoder) { nil }
  
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
    navBarSetUp()
  }
    
    func navBarSetUp() {
      title =  NSLocalizedString("Add new language", comment: "Add new language")
      navigationItem.leftBarButtonItem = UIBarButtonItem(title: NSLocalizedString("< Back", comment: "< Back"), style: .plain, target: self, action: #selector(actionGoBack))
    }
    
    @objc func actionGoBack() {
        coordinator?.popVC()
    }
}

// MARK: - Layout & Programmatic UI
extension NewLanguageViewController {
  
  private func setup() {
    // self.view.addSubview(newLanguageHeader)
    // self.newLanguageHeader.translatesAutoresizingMaskIntoConstraints = false
    
    self.view.addSubview(newLanguage)
    self.newLanguage.translatesAutoresizingMaskIntoConstraints = false
    
    self.view.addSubview(addButton)
    self.addButton.translatesAutoresizingMaskIntoConstraints = false
    self.addButton.addTarget(self, action: #selector(addLanguageAction), for: .touchUpInside)
  }
  
  private func layout() {
    fieldLayout()
    
    addLanguageLayout()
  }

  private func fieldLayout() {
    NSLayoutConstraint.activate([
        self.newLanguage.topAnchor.constraint(equalTo: view.topAnchor, constant: 120),
      self.newLanguage.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
      self.newLanguage.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
      self.newLanguage.heightAnchor.constraint(equalToConstant: 48)
    ])
  }
  
  private func addLanguageLayout() {
    NSLayoutConstraint.activate([
      self.addButton.topAnchor.constraint(equalToSystemSpacingBelow: newLanguage.bottomAnchor, multiplier: 4),
      self.addButton.leadingAnchor.constraint(equalTo: newLanguage.leadingAnchor),
      self.addButton.trailingAnchor.constraint(equalTo: newLanguage.trailingAnchor),
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
          coordinator?.popVC()
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
