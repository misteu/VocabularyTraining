//
//  ViewController.swift
//  VocabularyTrainer
//
//  Created by skrr on 10.03.19.
//  Copyright © 2019 mic. All rights reserved.
//

import UIKit

class HomeScreenViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, NewLanguageScreenProtocol {

  var languages = [String]()
  
  func setNewLanguage(language: String) {
    print("\(language) added")
  
  }

  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    tableView.delegate = self
    tableView.dataSource = self
    
    guard let rows = defaults.array(forKey: UserDefaultKeys.languages)?.count else { return}
    print("rows \(rows)")

    if let languages = defaults.array(forKey: UserDefaultKeys.languages) as? [String] {
      self.languages = languages
    }
    
  }
  
  override func viewDidAppear(_ animated: Bool) {
    tableView.reloadData()
    
    if let languages = defaults.array(forKey: UserDefaultKeys.languages) as? [String] {
      self.languages = languages
    }
    
    print("appear")
  }
  
  @IBOutlet weak var tableView: UITableView!
  
  let reuseIdentifier = "cell"
  let defaults = UserDefaults.standard
  
  func tableView(_ tbleView: UITableView, numberOfRowsInSection section: Int) -> Int {
    guard let rows = defaults.array(forKey: UserDefaultKeys.languages)?.count else { return 0}
    return rows
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
    if let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier) as? LanguageTableViewCell {
    
      guard let language = defaults.array(forKey: UserDefaultKeys.languages)?[indexPath.item] as? String else {print("no language string"); return UITableViewCell()}
      
      cell.languageLabel.text = language
      cell.languageWordsLabel.text = "\(Int.random(in: 1...200)) words"
      
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
  }
  
  var selectedLanguage = ""
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    selectedLanguage = languages[indexPath.item]
    performSegue(withIdentifier: SegueName.showLanguageSegue, sender: nil)
  }

}

