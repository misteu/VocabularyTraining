//
//  LanguageScreenViewController.swift
//  VocabularyTrainer
//
//  Created by skrr on 10.03.19.
//  Copyright © 2019 mic. All rights reserved.
//

import UIKit
import MessageUI

class VocabularyCell: UITableViewCell {
  @IBOutlet weak var vocabularyRoot: UILabel!
  @IBOutlet weak var vocabularyTranslation: UILabel!
  @IBOutlet weak var vocabularyProgress: UIProgressView!
  
  override func layoutSubviews() {
    super.layoutSubviews()
    backgroundColor = UIColor(white: 1.0, alpha: 0.0)
    vocabularyRoot.textColor = BackgroundColor.japaneseIndigo
    vocabularyTranslation.textColor = BackgroundColor.japaneseIndigo
    vocabularyProgress.progressTintColor = BackgroundColor.red
    vocabularyProgress.trackTintColor = BackgroundColor.mediumSpringBud
  }
  
  override func setSelected(_ selected: Bool, animated: Bool) {
    if selected {
      contentView.backgroundColor = BackgroundColor.hansaYellow
    } else {
        contentView.backgroundColor = UIColor.clear
    }
  }

}

class LanguageScreenViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, MFMailComposeViewControllerDelegate {
 
  @IBOutlet weak var searchBar: UISearchBar!
  
  @IBOutlet weak var backButton: UIButton!
  @IBOutlet weak var newWordButton: UIButton!
  @IBOutlet weak var deleteButton: UIButton!
  @IBOutlet weak var exportButton: UIButton!
  @IBOutlet weak var swipeToEditLabel: UILabel!
  @IBOutlet weak var tableView: UITableView!
  var selectedLanguage: String?
  var vocabularies = [(String,String,Float)]()
  var vocabDict = [String:String]()
  var vocabProgr = [String:Float]()
  var filteredData = [(String,String,Float)]()
  var isSearching = false
  var totalProgress = Float(0)
  var maxProgress = Float(0)
  var completed: (()->Void)?
  
  var delegate: NewLanguageScreenProtocol? = nil
  
  @IBOutlet weak var languageHeader: UILabel!
  
  
  override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    tableView.delegate = self
    tableView.dataSource = self
    searchBar.delegate = self
    
    guard let language = selectedLanguage else {return}
    languageHeader.text = language
    hideKeyboardWhenTappedAround()
    
    searchBar.layer.cornerRadius = 10.0
    searchBar.layer.borderWidth = 0.0
    searchBar.clipsToBounds = true
    styleUi()
    localize()
    setGradientBackground(view: view)
    }
  
  override func viewWillAppear(_ animated: Bool) {
    loadDataAndUpdate()
  }
  
  @IBAction func backButtonTapped(_ sender: Any) {
    completed?()
    dismiss(animated: true, completion: nil)
  }
  
  @IBAction func deleteButtonTapped(_ sender: Any) {
    
    // create the alert
    guard let language = selectedLanguage else { return }
    let alert = UIAlertController(title: String.localizedStringWithFormat(NSLocalizedString("Delete %@", comment: "Delete %@"), language), message: NSLocalizedString("Deleting this language will delete all your saved words and your learning progress.\nDo you want to proceed?", comment: "Deleting this language will delete all your saved words and your learning progress.\nDo you want to proceed?"), preferredStyle: UIAlertController.Style.alert)
    
    // add the actions (buttons)
    alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: "Cancel"), style: UIAlertAction.Style.cancel, handler: nil))
    alert.addAction(UIAlertAction(title: NSLocalizedString("Delete", comment: "Delete"), style: UIAlertAction.Style.destructive, handler: { action in
      
      guard let languages = UserDefaults.standard.array(forKey: UserDefaultKeys.languages) as? [String] else {print("error getting languages"); return}
      
      // create new language dataset w/o deleted language
      let newLanguages = languages.filter { $0 != language }
      UserDefaults.standard.set(newLanguages, forKey: UserDefaultKeys.languages)
      
      UserDefaults.standard.removeObject(forKey: language)
      UserDefaults.standard.removeObject(forKey: "\(language)Progress")
      
      
      self.dismiss(animated: true, completion: { () in
        if let delegate = self.delegate {
          delegate.updateLanguageTable(language: language)
        }
      })
    }))
    
    // show the alert
    self.present(alert, animated: true, completion: nil)
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    var result: Int;
    
    if isSearching {
      result = filteredData.count
    } else {
      result = vocabularies.count
    }
    
    if vocabularies.count == 0 {
      searchBar.isHidden = true
      tableView.isHidden = true
      swipeToEditLabel.text = NSLocalizedString("ℹ️ Add new words with the button below", comment: "ℹ️ Add new words with the button below")
      view.layoutIfNeeded()
    } else {
      searchBar.isHidden = false
      tableView.isHidden = false
      
      swipeToEditLabel.text = NSLocalizedString("Swipe left to edit word (edit its probability or delete it)", comment: "Swipe left to edit word (edit its probability or delete it)")
      
      view.layoutIfNeeded()
    }
    
    return result
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    if let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier.vocabularyCell) as? VocabularyCell {
      
      print("totalProgress: \(totalProgress)")
      
      if isSearching {
        cell.vocabularyRoot.text = filteredData[indexPath.item].0
        cell.vocabularyTranslation.text = filteredData[indexPath.item].1
        cell.vocabularyProgress.progress = filteredData[indexPath.item].2/maxProgress
        
      } else {
        
        cell.vocabularyRoot.text = vocabularies[indexPath.item].0
        cell.vocabularyTranslation.text = vocabularies[indexPath.item].1
        cell.vocabularyProgress.progress = vocabularies[indexPath.item].2/maxProgress
      }
      
      return cell
    }
    return UITableViewCell()
  }
  
  func loadVocabulary()->[String:String] {
    guard let language = selectedLanguage else {print("language not given"); return [String:String]()}

    guard let vocabulary = UserDefaults.standard.dictionary(forKey: language) as? [String:String] else {print("wrong dictionary format/not found"); return [String:String]()}
    return vocabulary
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == SegueName.showAddWordSegue {
      guard let secondVC = segue.destination as? AddNewWordViewController else { print("no segue found"); return}
      secondVC.selectedLanguage = selectedLanguage
      secondVC.completed = { [weak self] in
        self?.loadDataAndUpdate()
      }
    }
    
  }
  
  func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
    if searchBar.text == nil || searchBar.text == "" {
      isSearching = false
      view.endEditing(true)
      tableView.reloadData()
    } else {
      isSearching = true
      filteredData = vocabularies.filter({ $0.0.lowercased().contains(searchBar.text!.lowercased()) || $0.1.lowercased().contains(searchBar.text!.lowercased())})
      tableView.reloadData()
      
    }
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    
  }
  
  func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
    return true
  }
  
//  func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
//    if (editingStyle == .delete) {
//      if let cell = tableView.cellForRow(at: indexPath) as? VocabularyCell {
//        guard let key = cell.vocabularyRoot.text else { print("no cell"); return}
//
//        print(vocabDict)
//
//        vocabDict.removeValue(forKey: key)
//        vocabProgr.removeValue(forKey: key)
//
//        print("delete \(key)")
//
//        print(vocabDict)
//
//        guard  let language = selectedLanguage else {print("no language given"); return}
//
//        UserDefaults.standard.set(vocabDict, forKey: language)
//        UserDefaults.standard.set(vocabProgr, forKey: "\(language)Progress")
//
//        loadDataAndUpdate()
//      }
//    }
//  }
  
  
  func loadDataAndUpdate() {
    
    guard  let language = selectedLanguage else {print("no language given"); return}
    if let vocab = UserDefaults.standard.dictionary(forKey: language) as? [String:String] {
      vocabDict = vocab
    } else {
      vocabDict = [String:String]()
    }
    
    guard let vocabProgress = UserDefaults.standard.dictionary(forKey: "\(language)Progress") as? [String:Float] else { print("no progresses found"); return}
    vocabProgr = vocabProgress
    
    vocabularies = [(String,String,Float)]()
    for (key, value) in vocabDict {
      vocabularies.append((key,value,vocabProgress[key] ?? 100.0))
    }
    
    filteredData = vocabularies.filter({ $0.0.lowercased().contains(searchBar.text!.lowercased()) || $0.1.lowercased().contains(searchBar.text!.lowercased())})
    
    print(vocabularies)
    
    UIView.transition(with: tableView, duration: 0.3, options: .transitionCrossDissolve, animations: {self.tableView.reloadData()}, completion: nil)
    
    totalProgress = vocabularies.reduce(0){$0 + $1.2}
    
    if let maxItem = vocabularies.max(by: {$0.2 < $1.2 }) {
      let max = maxItem.2
      print("max progress: \(max)")
      maxProgress = max
    }
    
  }
  
  func convertToJSON(dic: NSDictionary)->String? {
    do {
      let jsonData = try JSONSerialization.data(withJSONObject: dic, options: .prettyPrinted)
      guard let result = String(data: jsonData, encoding: String.Encoding.utf8) else {return nil}
      // here "jsonData" is the dictionary encoded in JSON data
      print("saved")
      return result
    } catch {
      print(error.localizedDescription)
    }
    return nil
  }
  
  func sendEmail() {
    if MFMailComposeViewController.canSendMail() {
      let mail = MFMailComposeViewController()
      mail.mailComposeDelegate = self
      //mail.setToRecipients(["m.steudter@gmx.de"])
      
      let export = ["vocabularies": vocabDict, "progresses": vocabProgr] as [String : Any]
      
      mail.setMessageBody(convertToJSON(dic: export as NSDictionary) ?? "no vocabularies", isHTML: false)
      mail.setSubject("Vocabulary export")
      
      present(mail, animated: true)
    } else {
      // show failure alert
    }
  }
  
  func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
    controller.dismiss(animated: true)
  }
  
  @IBAction func exportButtonTapped(_ sender: Any) {
    //sendEmail()
    //exportToDocuments()
    exportAsCsvToDocuments()
  }
  
  func styleUi() {
    newWordButton.backgroundColor = BackgroundColor.mediumSpringBud
    newWordButton.layer.cornerRadius = 5.0
    newWordButton.setTitleColor(BackgroundColor.japaneseIndigo, for: .normal)
    
    deleteButton.backgroundColor = BackgroundColor.red
    deleteButton.layer.cornerRadius = 5.0
    deleteButton.contentEdgeInsets = UIEdgeInsets.init(top: 0, left: 10, bottom: 0, right: 10)
    deleteButton.setTitleColor(BackgroundColor.mediumWhite, for: .normal)
    
    backButton.backgroundColor = BackgroundColor.hansaYellow
    backButton.layer.cornerRadius = 5.0
    backButton.contentEdgeInsets = UIEdgeInsets.init(top: 0, left: 10, bottom: 0, right: 10)
    backButton.setTitleColor(BackgroundColor.japaneseIndigo, for: .normal)
    
    tableView.backgroundColor = UIColor(white: 1.0, alpha: 0.3)
    tableView.layer.cornerRadius = 10.0
    
    exportButton.setTitleColor(BackgroundColor.japaneseIndigo, for: .normal)
    exportButton.backgroundColor = UIColor(white: 1.0, alpha: 0.3)
    exportButton.layer.cornerRadius = 5.0
    exportButton.contentEdgeInsets = UIEdgeInsets(top: 4.0, left: 4.0, bottom: 4.0, right: 4.0)
    
    searchBar.tintColor = UIColor(white: 1.0, alpha: 0.3)
  
  }
  
  func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
    
    let deleteAction = UITableViewRowAction(style: .default, title: NSLocalizedString("Delete", comment: "Delete") , handler: { (action:UITableViewRowAction, indexPath:IndexPath) -> Void in
      
            if let cell = tableView.cellForRow(at: indexPath) as? VocabularyCell {
              guard let key = cell.vocabularyRoot.text else { print("no cell"); return}
      
              print(self.vocabDict)
      
              self.vocabDict.removeValue(forKey: key)
              self.vocabProgr.removeValue(forKey: key)
      
              print("delete \(key)")
      
              print(self.vocabDict)
      
              guard  let language = self.selectedLanguage else {print("no language given"); return}
      
              UserDefaults.standard.set(self.vocabDict, forKey: language)
              UserDefaults.standard.set(self.vocabProgr, forKey: "\(language)Progress")
      
              self.loadDataAndUpdate()
            }
      
    })
    
    let editAction = UITableViewRowAction(style: .normal, title: "\(NSLocalizedString("Edit:", comment: "Edit:")) \(Int.init(vocabularies[indexPath.item].2))/\(Int.init(maxProgress))" , handler: { (action:UITableViewRowAction, indexPath:IndexPath) -> Void in
      
      guard let cell = tableView.cellForRow(at: indexPath) as? VocabularyCell else {return}
      guard let key = cell.vocabularyRoot.text else { print("no cell"); return}
      guard let language = self.selectedLanguage else {print("no language selected"); return}
      
      let alert = UIAlertController(title: NSLocalizedString("Change word`s probability", comment: "Change word`s probability"), message: NSLocalizedString("Change word`s probability value. Higher value -> higher probability for word to appear.\nNew words start with 100.", comment: "Change word`s probability value. Higher value -> higher probability for word to appear.\nNew words start with 100."), preferredStyle: .alert)
      
      alert.addTextField { (textField) in
        
        guard let progress = self.vocabProgr[key] else {print("no progress found"); return}
        textField.text = "\(Int.init(progress))"
      }
      
      // 3. Grab the value from the text field, and print it when the user clicks OK.
      alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in
        let textField = alert?.textFields![0] // Force unwrapping because we know it exists.
        print("Text field: \(String(describing: textField?.text))")
        
        guard let input = textField?.text else {return}
        var newProgress = (input as NSString).floatValue
        if (newProgress < 1) {
          newProgress = 1
        }
        self.vocabProgr[key] = newProgress
        
        UserDefaults.standard.set(self.vocabProgr, forKey: "\(language)Progress")
        
        self.loadDataAndUpdate()
        tableView.reloadData()
        
      }))
      alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: { (_) in
        
      }))
      
      // 4. Present the alert.
      self.present(alert, animated: true, completion: nil)
      
    })
    
    editAction.backgroundColor = BackgroundColor.fullBlue

    // 5
    return [deleteAction,editAction]
  }
  
  func exportToDocuments() {
    let export = ["vocabularies": vocabDict, "progresses": vocabProgr] as [String : Any]
    
    // Get the url of Persons.json in document directory
    guard let documentDirectoryUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
    guard let language = selectedLanguage else {print("no language selected"); return}
    let fileUrl = documentDirectoryUrl.appendingPathComponent("\(language).json")

    
    // Transform array into data and save it into file
    do {
      let data = try JSONSerialization.data(withJSONObject: export, options: .prettyPrinted)
      try data.write(to: fileUrl, options: [])
    } catch {
      print(error)
    }
  }
  
  func exportAsCsvToDocuments() {
    
    guard let language = selectedLanguage else {print("no language selected"); return}
    
    let exportStringHead = """
    \(language)
    word;translation;progress
    """
    var exportString = ""
    
    for (key, value) in vocabDict {
      
      if exportString != "" {
        exportString = """
        \(exportString)
        \(key);\(value);\(vocabProgr[key] ?? 100)
        """
      } else {
        exportString = "\(key);\(value);\(vocabProgr[key] ?? 100)"
      }
    }
    
    exportString = """
    \(exportStringHead)
    \(exportString)
    """
    
    let file = "\(language).csv"
    if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
      
      let fileURL = dir.appendingPathComponent(file)
      
      //writing
      do {
        try exportString.write(to: fileURL, atomically: false, encoding: .macOSRoman)
        let alert = UIAlertController(title: "\(NSLocalizedString("Export successful:", comment: "Export successful:")) \(language).csv", message: String.localizedStringWithFormat(NSLocalizedString("You may copy your file to your machine via iTunes:\n iPhone->Filesharing->Flippy->drag %@.csv into Finder", comment: "You may copy your file to your machine via iTunes:\n iPhone->Filesharing->Flippy->drag %@.csv into Finder"), language)
          , preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
      }
      catch {/* error handling here */}
      
//      //reading
//      do {
//        let text2 = try String(contentsOf: fileURL, encoding: .utf8)
//      }
//      catch {/* error handling here */}
    }
    
  }
  
  func localize() {
    backButton.setTitle(NSLocalizedString("< Back", comment: "< Back"), for: .normal)
    deleteButton.setTitle(NSLocalizedString("Delete Language", comment: "Delete Language"), for: .normal)
    newWordButton.setTitle(NSLocalizedString("New word", comment: "New word"), for: .normal)
    exportButton.setTitle(NSLocalizedString("export", comment: "export"), for: .normal)
    searchBar.placeholder = NSLocalizedString("search for words", comment: "search for words")
  
    swipeToEditLabel.text = NSLocalizedString("Swipe left to edit word (edit its probability or delete it)", comment: "Swipe left to edit word (edit its probability or delete it)")
  }

  
  
}
