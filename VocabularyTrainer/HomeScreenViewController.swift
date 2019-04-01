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

struct LanguageImport {
  var vocabularies: [String:String]
  var progresses:[String:Float]
  
  init(vocabularies: [String:String], progresses: [String:Float]) {
    self.vocabularies = vocabularies
    self.progresses = progresses
  }
}

class HomeScreenViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, NewLanguageScreenProtocol {
  @IBOutlet var topButtons: [UIButton]!
  
  @IBOutlet weak var addLanguageButton: UIButton!
  @IBOutlet weak var headerTextConstraintTop: NSLayoutConstraint!
  var languages = [String]()
  var selectedRow: Int? = nil
  private let refreshControl = UIRefreshControl()
  
  func setNewLanguage(language: String) {
    print("\(language) added")
  
  }


  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    for button in topButtons {
      button.isHidden = true
      button.alpha = 0.0
      if !(button.title(for: .normal) == "My vocabulary") {
        button.backgroundColor = BackgroundColor.yellow
      } else {
        button.backgroundColor = BackgroundColor.blue
      }
      button.layer.cornerRadius = 5.0
      button.setTitleColor(.white, for: .normal)
      button.contentEdgeInsets = UIEdgeInsets.init(top: 0, left: 10, bottom: 0, right: 10)
      
    }
    headerTextConstraintTop.constant = 32.0
    
    tableView.delegate = self
    tableView.dataSource = self
    
    guard let rows = defaults.array(forKey: UserDefaultKeys.languages)?.count else { return}
    print("rows \(rows)")

    if let languages = defaults.array(forKey: UserDefaultKeys.languages) as? [String] {
      self.languages = languages
    }
    
    hideKeyboardWhenTappedAround()
    
    addLanguageButton.backgroundColor = BackgroundColor.green
    addLanguageButton.layer.cornerRadius = 5.0
    addLanguageButton.setTitleColor(.white, for: .normal)
    
    if #available(iOS 10.0, *) {
      tableView.refreshControl = refreshControl
    } else {
      tableView.addSubview(refreshControl)
    }
    
    refreshControl.addTarget(self, action: #selector(reloadImports), for: .valueChanged)
    
  }
  
  override func viewWillAppear(_ animated: Bool) {
    
    if let languages = defaults.array(forKey: UserDefaultKeys.languages) as? [String] {
      self.languages = languages
    }
    
    tableView.reloadData()
    
    print("appear")
  }
  
  @IBOutlet weak var tableView: UITableView!
  
  let defaults = UserDefaults.standard
  
  func tableView(_ tbleView: UITableView, numberOfRowsInSection section: Int) -> Int {
    guard let rows = defaults.array(forKey: UserDefaultKeys.languages)?.count else { return 0}
    return rows
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
    if let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier.languageCell) as? LanguageTableViewCell {
      
      let selectedView = UIView()
      selectedView.backgroundColor = BackgroundColor.lightBlue
      selectedView.layer.cornerRadius = 5.0
      cell.selectedBackgroundView = selectedView
    
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
    
    self.headerTextConstraintTop.constant = 68.0
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
    
    if areWordsSavedFor(language: selectedLanguage) {
      performSegue(withIdentifier: SegueName.showTrainingSegue, sender: nil)
    } else {
      showToast(message: "No words inside 🕵️‍♀️", yCoord: view.frame.maxY/2)
    }
    
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
  
  func areWordsSavedFor(language: String)->Bool {
    guard let _ = UserDefaults.standard.dictionary(forKey: language) as? [String:String] else { print("no vocabularies found"); return false}
    return true
  }
  
  func importLanguageFile(language: String)->String {
    let file = "\(language).csv"
    var result = ""
    
    if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
      let fileURL = dir.appendingPathComponent(file)
      
      do {
        result = try String(contentsOf: fileURL, encoding: .macOSRoman)
      }
      catch {/* error handling here */}
      
    }
    return result
  }
  
  func csv(data: String) -> LanguageImport {
    var vocabDict = [String:String]()
    var vocabProgr = [String:Float]()
    
    let rows = data.components(separatedBy: "\n")
    for (index,row) in rows.enumerated() {
      if index > 0 {
        let columns = row.components(separatedBy: ";")
        vocabDict[columns[0]] = columns[1]
        vocabProgr[columns[0]] = (columns[2] as NSString).floatValue
      }
    }
    
    let result = LanguageImport.init(vocabularies: vocabDict, progresses: vocabProgr)
  
    return result
  }
  
  func updateUserDefFromImports(imports: LanguageImport) {
    let language = "test"
    let languageVocabProgressKey = "\(language)Progress"
    
    UserDefaults.standard.set(imports.vocabularies, forKey: language)
    UserDefaults.standard.set(imports.progresses, forKey: languageVocabProgressKey)
    
    if let savedLanguages = UserDefaults.standard.array(forKey: UserDefaultKeys.languages) as? [String] {
      
      for lang in savedLanguages {
        if lang == language { return }
      }
      
      var languages = savedLanguages
      languages.append(language)
      UserDefaults.standard.set(languages, forKey: UserDefaultKeys.languages)
      
    } else {
      UserDefaults.standard.set([language], forKey: UserDefaultKeys.languages)
    }
    
  }
  
  
  /// TODO: universal language file support
  @objc func reloadImports() {
    let rawCsvImport = importLanguageFile(language: "test")
    let importedCsvAsDicts = csv(data: rawCsvImport)
    updateUserDefFromImports(imports: importedCsvAsDicts)
    
    if let languages = defaults.array(forKey: UserDefaultKeys.languages) as? [String] {
      self.languages = languages
    }
    
    tableView.reloadData()
    self.refreshControl.endRefreshing()
    self.view.layoutIfNeeded()
  }
  
}

