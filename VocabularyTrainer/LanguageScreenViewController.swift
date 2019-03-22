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
  
}

class LanguageScreenViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, MFMailComposeViewControllerDelegate {
 
  @IBOutlet weak var searchBar: UISearchBar!
  
  @IBOutlet weak var backButton: UIButton!
  @IBOutlet weak var newWordButton: UIButton!
  @IBOutlet weak var tableView: UITableView!
  var selectedLanguage: String?
  var vocabularies = [(String,String,Float)]()
  var vocabDict = [String:String]()
  var vocabProgr = [String:Float]()
  var filteredData = [(String,String,Float)]()
  var isSearching = false
  var totalProgress = Float(0)
  
  @IBOutlet weak var languageHeader: UILabel!
  
  @IBOutlet weak var deleteButton: UIButton!
  
  override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    tableView.delegate = self
    tableView.dataSource = self
    searchBar.delegate = self
    
    guard let language = selectedLanguage else {return}
    languageHeader.text = language
    hideKeyboardWhenTappedAround()
    
    styleButtons()
    
    }
  
  override func viewWillAppear(_ animated: Bool) {
    
    loadDataAndUpdate()
  }
    
  @IBAction func backButtonTapped(_ sender: Any) {
    dismiss(animated: true, completion: nil)
  }
  
  @IBAction func deleteButtonTapped(_ sender: Any) {
    
    // create the alert
    guard let language = selectedLanguage else { return }
    let alert = UIAlertController(title: "Delete \(language)", message: "Deleting this language will delete all your saved vocabulary and your learning progress.\n Do you want to proceed?", preferredStyle: UIAlertController.Style.alert)
    
    // add the actions (buttons)
    alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil))
    alert.addAction(UIAlertAction(title: "Delete", style: UIAlertAction.Style.destructive, handler: { action in
      
      guard let languages = UserDefaults.standard.array(forKey: UserDefaultKeys.languages) as? [String] else {print("error getting languages"); return}
      
      // create new language dataset w/o deleted language
      let newLanguages = languages.filter { $0 != language }
      UserDefaults.standard.set(newLanguages, forKey: UserDefaultKeys.languages)
      
      UserDefaults.standard.removeObject(forKey: language)
      UserDefaults.standard.removeObject(forKey: "\(language)Progress")
      
      
      self.dismiss(animated: true, completion: nil)
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
    } else {
      searchBar.isHidden = false
    }
    
    return result
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    if let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier.vocabularyCell) as? VocabularyCell {
      
      print("maxProgress: \(totalProgress)")
      
      if isSearching {
        cell.vocabularyRoot.text = filteredData[indexPath.item].0
        cell.vocabularyTranslation.text = filteredData[indexPath.item].1
        cell.vocabularyProgress.progress = 1-filteredData[indexPath.item].2/totalProgress
        
      } else {
        
        cell.vocabularyRoot.text = vocabularies[indexPath.item].0
        cell.vocabularyTranslation.text = vocabularies[indexPath.item].1
        cell.vocabularyProgress.progress = 1-vocabularies[indexPath.item].2/totalProgress
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
  
  func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
    if (editingStyle == .delete) {
      if let cell = tableView.cellForRow(at: indexPath) as? VocabularyCell {
        guard let key = cell.vocabularyRoot.text else { print("no cell"); return}
        
        print(vocabDict)
        
        vocabDict.removeValue(forKey: key)
        vocabProgr.removeValue(forKey: key)
        
        print("delete \(key)")
        
        print(vocabDict)
        
        guard  let language = selectedLanguage else {print("no language given"); return}
        
        UserDefaults.standard.set(vocabDict, forKey: language)
        UserDefaults.standard.set(vocabProgr, forKey: "\(language)Progress")
        
        loadDataAndUpdate()
      }
    }
  }
  
  
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
    sendEmail()
  }
  
  func styleButtons() {
    newWordButton.backgroundColor = BackgroundColor.green
    newWordButton.layer.cornerRadius = 5.0
    newWordButton.setTitleColor(.white, for: .normal)
    
    deleteButton.backgroundColor = BackgroundColor.red
    deleteButton.layer.cornerRadius = 5.0
    deleteButton.contentEdgeInsets = UIEdgeInsets.init(top: 0, left: 10, bottom: 0, right: 10)
    deleteButton.setTitleColor(.white, for: .normal)
    
    backButton.backgroundColor = BackgroundColor.blue
    backButton.layer.cornerRadius = 5.0
    backButton.contentEdgeInsets = UIEdgeInsets.init(top: 0, left: 10, bottom: 0, right: 10)
    backButton.setTitleColor(.white, for: .normal)
    
    backButton.backgroundColor = BackgroundColor.blue
    backButton.layer.cornerRadius = 5.0
    backButton.contentEdgeInsets = UIEdgeInsets.init(top: 0, left: 10, bottom: 0, right: 10)
    backButton.setTitleColor(.white, for: .normal)
    
  }
  
}
