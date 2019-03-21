//
//  ViewController.swift
//  VocabularyTrainer
//
//  Created by skrr on 10.03.19.
//  Copyright © 2019 mic. All rights reserved.
//

import UIKit

class LanguageTableViewCell: UITableViewCell {
  
  @IBOutlet weak var languageLabel: UILabel!
  @IBOutlet weak var languageWordsLabel: UILabel!
  
}

class HomeScreenViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, NewLanguageScreenProtocol {
  @IBOutlet var topButtons: [UIButton]!
  
  @IBOutlet weak var headerTextConstraintTop: NSLayoutConstraint!
  var languages = [String]()
  var selectedRow: Int? = nil
  
  func setNewLanguage(language: String) {
    print("\(language) added")
  
  }


  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    for button in topButtons {
      button.isHidden = true
      button.alpha = 0.0
    }
    headerTextConstraintTop.constant = 16.0
    
    tableView.delegate = self
    tableView.dataSource = self
    
    guard let rows = defaults.array(forKey: UserDefaultKeys.languages)?.count else { return}
    print("rows \(rows)")

    if let languages = defaults.array(forKey: UserDefaultKeys.languages) as? [String] {
      self.languages = languages
    }
    
    hideKeyboardWhenTappedAround()
    
  }
  
  override func viewWillAppear(_ animated: Bool) {
    
    if let languages = defaults.array(forKey: UserDefaultKeys.languages) as? [String] {
      self.languages = languages
    }
    
    tableView.reloadData()
    
    print("appear")
  }
  
  override func viewDidAppear(_ animated: Bool) {

  }
  
  @IBOutlet weak var tableView: UITableView!
  
  let defaults = UserDefaults.standard
  
  func tableView(_ tbleView: UITableView, numberOfRowsInSection section: Int) -> Int {
    guard let rows = defaults.array(forKey: UserDefaultKeys.languages)?.count else { return 0}
    return rows
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
    if let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier.languageCell) as? LanguageTableViewCell {
    
      guard let language = defaults.array(forKey: UserDefaultKeys.languages)?[indexPath.item] as? String else {print("no language string"); return UITableViewCell()}
      
      cell.languageLabel.text = language
      
      if let vocabularies = UserDefaults.standard.dictionary(forKey: language) as? [String:String] {
        
        if (vocabularies.count > 1 || vocabularies.count == 0) {
          cell.languageWordsLabel.text = "\(vocabularies.count) words"
        } else {
          cell.languageWordsLabel.text = "\(vocabularies.count) word"
        }
        
      } else {
        print("no vocab loadable")
        cell.languageWordsLabel.text = "0 words"
      }
      

      
      return cell
    }
    return UITableViewCell()
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == SegueName.showNewLanguageScreenSegue {
      let secondVC = segue.destination as! NewLanguageViewController
      secondVC.delegate = self
    }
    
    if segue.identifier == SegueName.showLanguageSegue {
      let secondVC = segue.destination as! LanguageScreenViewController
      secondVC.selectedLanguage = selectedLanguage
    }
    
    if segue.identifier == SegueName.showTrainingSegue {
      let secondVC = segue.destination as! TrainingViewController
      secondVC.selectedLanguage = selectedLanguage
    }
  }
  
  var selectedLanguage = ""
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    selectedRow = indexPath.item
    
    self.headerTextConstraintTop.constant = 52.0
    UIView.animate(withDuration: 0.2, animations: {
      self.view.layoutIfNeeded()
      for button in self.topButtons {
        button.alpha = 1.0
        button.isHidden = false
      }
    })

  }

  @IBAction func trainingButton(_ sender: Any) {
    deactivateTopButtons()
    
    guard let row = selectedRow else {print("nothing selected"); return}
    selectedLanguage = languages[row]
    
    performSegue(withIdentifier: SegueName.showTrainingSegue, sender: nil)
    
  }
  @IBAction func editButton(_ sender: Any) {
    
    deactivateTopButtons()
    
    guard let row = selectedRow else {print("nothing selected"); return}
    
    selectedLanguage = languages[row]
    performSegue(withIdentifier: SegueName.showLanguageSegue, sender: nil)
    
  }
  
  func deactivateTopButtons() {
    self.headerTextConstraintTop.constant = 16.0
    UIView.animate(withDuration: 0.2, animations: {
      self.view.layoutIfNeeded()
      for button in self.topButtons {
        button.alpha = 0.0
      }
    }, completion: {res in
      for button in self.topButtons {
        button.isHidden = true
      }
    })
  }
  
}

