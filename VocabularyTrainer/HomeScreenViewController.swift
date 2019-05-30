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
  
  override func layoutSubviews() {
    super.layoutSubviews()
    backgroundColor = UIColor(white: 1.0, alpha: 0.0)
    if let background = backgroundView {
      background.frame = background.frame.inset(by: UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5))
    }
    languageLabel.textColor = BackgroundColor.japaneseIndigo
    languageWordsLabel.textColor = BackgroundColor.japaneseIndigo
    
    guard let selected = selectedBackgroundView else { return }
    selected.frame = selected.frame.inset(by: UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5))
  }
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
  @IBOutlet weak var headerText: UILabel!
  @IBOutlet weak var importButton: UIButton!
  
  var languages = [String]()
  var selectedRow: Int? = nil
  private let refreshControl = UIRefreshControl()
  
  func setNewLanguage(language: String) {
    debugPrint("\(language) added")
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    
    for button in topButtons {
      button.isHidden = true
      button.alpha = 0.0
      button.layer.cornerRadius = 5.0
      button.setTitleColor(.black, for: .normal)
      button.contentEdgeInsets = UIEdgeInsets.init(top: 0, left: 10, bottom: 0, right: 10)
    }
    
    styleUi()
    localize()
  
    headerTextConstraintTop.constant = 32.0
    
    tableView.delegate = self
    tableView.dataSource = self
    
    guard let rows = defaults.array(forKey: UserDefaultKeys.languages)?.count else { return}
    debugPrint("rows \(rows)")

    if let languages = defaults.array(forKey: UserDefaultKeys.languages) as? [String] {
      self.languages = languages
    }
    
    hideKeyboardWhenTappedAround()
    
    if #available(iOS 10.0, *) {
      tableView.refreshControl = refreshControl
    } else {
      tableView.addSubview(refreshControl)
    }
    refreshControl.addTarget(self, action: #selector(reloadImports), for: .valueChanged)
  
    debugPrint(getAllLanguageFileUrls())
  }
  
  override func viewWillAppear(_ animated: Bool) {
    
    if let languages = defaults.array(forKey: UserDefaultKeys.languages) as? [String] {
      self.languages = languages
    }
    
    tableView.reloadData()
    setGradientBackground(view: view)
  }
  
  @IBOutlet weak var tableView: UITableView!
  
  let defaults = UserDefaults.standard
  
  func tableView(_ tbleView: UITableView, numberOfRowsInSection section: Int) -> Int {
    guard let rows = defaults.array(forKey: UserDefaultKeys.languages)?.count else { return 0}
    if rows < 1 {
      let noLanguagesLabel = UILabel(frame: CGRect(x: 20, y: view.frame.maxY/2-75, width: view.frame.width-40, height: 150))
      noLanguagesLabel.text = NSLocalizedString("Currently there are no languages", comment: "Currently there are no languages")
      noLanguagesLabel.textAlignment = .center
      noLanguagesLabel.numberOfLines = 0
      noLanguagesLabel.tag = 99
      view.addSubview(noLanguagesLabel)
    } else {
      view.viewWithTag(99)?.removeFromSuperview()
    }
    return rows
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
    if let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier.languageCell) as? LanguageTableViewCell {
      
//      let selectedView = UIView()
//      selectedView.backgroundColor = BackgroundColor.lightBlue
//      selectedView.frame = selectedView.frame.inset(by: UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5))
//      cell.selectedBackgroundView = selectedView
//      cell.backgroundView = selectedView
      
      guard let language = defaults.array(forKey: UserDefaultKeys.languages)?[indexPath.item] as? String else { debugPrint("no language string"); return UITableViewCell() }
      
      cell.languageLabel.text = language
      
      if let vocabularies = UserDefaults.standard.dictionary(forKey: language) as? [String:String] {
        
        if (vocabularies.count > 1 || vocabularies.count == 0) {
//          cell.languageWordsLabel.text = "\(vocabularies.count) words"
          cell.languageWordsLabel.text = String.localizedStringWithFormat(NSLocalizedString("%d words", comment: "%d words"), vocabularies.count)
        } else {
//          cell.languageWordsLabel.text = "\(vocabularies.count) word"
          cell.languageWordsLabel.text = String.localizedStringWithFormat(NSLocalizedString("%d word", comment: "%d word"), vocabularies.count)
        }
        
      } else {
        debugPrint("no vocab loadable")
        cell.languageWordsLabel.text = NSLocalizedString("0 words", comment: "0 words")
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
    
    
//      for cell in tableView.visibleCells{
//        if cell.isSelected{
//          UIView.animate(withDuration: 0.3, animations: {
//            cell.backgroundView?.backgroundColor = BackgroundColor.red
//          })
//        } else {
//          UIView.animate(withDuration: 0.3, animations: {
//            let selectedView = UIView()
//            selectedView.backgroundColor = BackgroundColor.lightBlue
//            selectedView.layer.cornerRadius = 5.0
//            selectedView.frame = selectedView.frame.inset(by: UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5))
//            cell.backgroundView = selectedView
//          })
//        }
//      }
  }
  
  @IBAction func trainingButton(_ sender: Any) {
    deactivateTopButtons()
    
    guard let row = selectedRow else {debugPrint("nothing selected"); return}
    selectedLanguage = languages[row]
    
    if areWordsSavedFor(language: selectedLanguage) {
      performSegue(withIdentifier: SegueName.showTrainingSegue, sender: nil)
    } else {
      showToast(message: NSLocalizedString("No words inside 🕵️‍♀️", comment: "No words inside 🕵️‍♀️"), yCoord: view.frame.maxY/2)
    }
    
  }
  @IBAction func editButton(_ sender: Any) {
    
    deactivateTopButtons()
    
    guard let row = selectedRow else {debugPrint("nothing selected"); return}
    
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
    guard let _ = UserDefaults.standard.dictionary(forKey: language) as? [String:String] else { debugPrint("no vocabularies found"); return false}
    return true
  }
  
  func importLanguageFile(language: String)->String {
    let file = language
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
  
  func getAllLanguageFileUrls()->[URL]? {
    if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
      
      do {
        let directoryContents = try FileManager.default.contentsOfDirectory(at: dir, includingPropertiesForKeys: nil, options: [])
        return directoryContents
      }
      catch {
        return nil
      }
    }
    return nil
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
  
  func updateUserDefFromImports(imports: LanguageImport, language: String) {
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
    
    guard let files = getAllLanguageFileUrls() else { return }
    
    for file in files {
      debugPrint(file.lastPathComponent)
      let rawCsvImport = importLanguageFile(language: file.lastPathComponent)
      let importedCsvAsDicts = csv(data: rawCsvImport)
      updateUserDefFromImports(imports: importedCsvAsDicts, language: file.deletingPathExtension().lastPathComponent)
      
      if let languages = defaults.array(forKey: UserDefaultKeys.languages) as? [String] {
        self.languages = languages
      }
    }
    
    tableView.reloadData()
    self.refreshControl.endRefreshing()
    self.view.layoutIfNeeded()
  }
  
  @IBAction func tappedImportButton(_ sender: Any) {
    spinner(start: true)
    reloadImports()
    _ = Timer.scheduledTimer(withTimeInterval: 0.4, repeats: false, block: {_ in self.spinner(start: false)})
  }
  
  func styleUi() {
    addLanguageButton.backgroundColor = BackgroundColor.mediumSpringBud
    addLanguageButton.layer.cornerRadius = 5.0
    addLanguageButton.contentEdgeInsets = UIEdgeInsets.init(top: 0, left: 10, bottom: 0, right: 10)
    addLanguageButton.setTitleColor(BackgroundColor.japaneseIndigo, for: .normal)
  
    topButtons[0].backgroundColor = BackgroundColor.mediumSpringBud
    topButtons[0].setTitleColor(BackgroundColor.japaneseIndigo, for: .normal)
    topButtons[1].backgroundColor = BackgroundColor.hansaYellow
    topButtons[1].setTitleColor(BackgroundColor.japaneseIndigo, for: .normal)
    
    importButton.setTitleColor(BackgroundColor.japaneseIndigo, for: .normal)
    importButton.backgroundColor = UIColor(white: 1.0, alpha: 0.3)
    importButton.layer.cornerRadius = 5.0
    importButton.contentEdgeInsets = UIEdgeInsets(top: 4.0, left: 4.0, bottom: 4.0, right: 4.0)
    
    headerText.textColor = BackgroundColor.japaneseIndigo
    
    tableView.backgroundColor = UIColor(white: 1.0, alpha: 0.3)
    tableView.layer.cornerRadius = 10.0
  
  }
  
  func localize() {
    headerText.text = NSLocalizedString("Your Languages", comment: "Your Languages")
    addLanguageButton.setTitle(NSLocalizedString("Add language", comment: "Add language"), for: .normal)
    
    topButtons[0].setTitle(NSLocalizedString("Training", comment: "Training"), for: .normal)
    topButtons[1].setTitle(NSLocalizedString("My words", comment: "settings"), for: .normal)
    importButton.setTitle(NSLocalizedString("⤵ import", comment: "⤵ import"), for: .normal)
  }
  
  func spinner(start: Bool) {
    let spinner = UIActivityIndicatorView(style: .whiteLarge)
    if start {
      spinner.startAnimating()
      spinner.tag = 123
      tableView.backgroundView = spinner
    } else {
      guard let spinner = tableView.viewWithTag(123) as? UIActivityIndicatorView else { return }
      spinner.stopAnimating()
    }
    
  }
}

