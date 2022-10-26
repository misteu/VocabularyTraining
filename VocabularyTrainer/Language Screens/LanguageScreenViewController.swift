//
//  LanguageScreenViewController.swift
//  VocabularyTrainer
//
//  Created by skrr on 10.03.19.
//  Copyright © 2019 mic. All rights reserved.
//

import UIKit
import MessageUI

class LanguageScreenViewController: UIViewController, UISearchBarDelegate, MFMailComposeViewControllerDelegate {
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var newWordButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var exportButton: UIButton!
    @IBOutlet weak var sortWordButton: UIButton!
    @IBOutlet weak var sortTranslationButton: UIButton!
    @IBOutlet weak var sortDateButton: UIButton!
    @IBOutlet weak var hintLabel: UILabel!
    
    @IBOutlet weak var tableView: UITableView!
    var selectedLanguage: String?
    var vocabularies = [(word: String, translation: String, progress: Float, addedDate: Date?)]()
    var vocabDict = [String: String]()
    var vocabProgr = [String: Float]()
    var filteredData = [(word: String, translation: String, progress: Float, addedDate: Date?)]()
    var isSearching = false
    var totalProgress = Float(0)
    var maxProgress = Float(0)
    var completed: (() -> Void)?
    
    /// Sorting directions for the vocabulary list.
    var isSortingAscending = (word: false, translation: false, date: false)
    
    /// The info text that will appear when tapping on the info button.
    var infoText = ""
    
    enum SortElement {
        case word
        case translation
        case date
    }
    
    var delegate: NewLanguageScreenProtocol?
    
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
        loadDataAndUpdate()
        sortVocabulary(element: .word, isAscending: true)
        wordAddedObserver()
    }
    
    private func wordAddedObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(reloadData), name: .wordAdded, object: nil)
    }
    
    @objc private func reloadData() {
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
        alert.addAction(UIAlertAction(title: NSLocalizedString("Delete", comment: "Delete"), style: UIAlertAction.Style.destructive, handler: { _ in
            
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
        
    @IBAction func infoButtonTapped(_ sender: Any) {
        let alert = UIAlertController(title: nil,
                                      message: infoText,
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: "Cancel"),
                                      style: .cancel,
                                      handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    @IBAction func newWordButtonTapped(_ sender: Any) {
        let viewController = AddNewWordViewController(selectedLanguage: selectedLanguage)
        self.present(viewController, animated: true)
    }
    
    @IBAction func sortButtonTapped(_ sender: UIButton) {
        
        let configuration = UIImage.SymbolConfiguration(textStyle: .title1, scale: .large)
        let chevronUpImage = UIImage(systemName: "chevron.up.square.fill", withConfiguration: configuration)
        let chevronDownImage = UIImage(systemName: "chevron.down.square.fill", withConfiguration: configuration)
        let minusImage = UIImage(systemName: "minus.square.fill", withConfiguration: configuration)
        
        if sender === sortWordButton {
            sortWordButton.setImage(isSortingAscending.word ? chevronUpImage : chevronDownImage, for: .normal)
            sortTranslationButton.setImage(minusImage, for: .normal)
            sortDateButton.setImage(minusImage, for: .normal)
            sortVocabulary(element: .word, isAscending: isSortingAscending.word)
            isSortingAscending.word.toggle()
        } else if sender === sortTranslationButton {
            sortTranslationButton.setImage(isSortingAscending.translation ? chevronUpImage : chevronDownImage, for: .normal)
            sortWordButton.setImage(minusImage, for: .normal)
            sortDateButton.setImage(minusImage, for: .normal)
            sortVocabulary(element: .translation, isAscending: isSortingAscending.translation)
            isSortingAscending.translation.toggle()
        } else if sender === sortDateButton {
            sortDateButton.setImage(isSortingAscending.date ? chevronUpImage : chevronDownImage, for: .normal)
            sortTranslationButton.setImage(minusImage, for: .normal)
            sortWordButton.setImage(minusImage, for: .normal)
            sortVocabulary(element: .date, isAscending: isSortingAscending.date)
            isSortingAscending.date.toggle()
        }
        
        tableView.reloadData()
    }
    
    private func sortVocabulary(element: SortElement, isAscending: Bool) {
        
        switch element {
        case .word:
            vocabularies.sort(by: {
                isAscending ? $0.word.lowercased() < $1.word.lowercased() : $0.word.lowercased() > $1.word.lowercased()
            })
            
        case .translation:
            vocabularies.sort(by: {
                isAscending ? $0.translation.lowercased() < $1.translation.lowercased() : $0.translation.lowercased() > $1.translation.lowercased()
            })
        case .date:
            let defaultDate = Date.init(timeIntervalSince1970: 0)
            vocabularies.sort(by: {
                isAscending ? $0.addedDate ?? defaultDate < $1.addedDate ?? defaultDate: $0.addedDate ?? defaultDate > $1.addedDate  ?? defaultDate
            })
        }
    }
        
    func loadVocabulary() -> [String: String] {
        guard let language = selectedLanguage else {print("language not given"); return [String: String]()}
        
        guard let vocabulary = UserDefaults.standard.dictionary(forKey: language) as? [String: String] else {print("wrong dictionary format/not found"); return [String: String]()}
        return vocabulary
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text == nil || (searchBar.text?.isEmpty ?? false) {
            isSearching = false
            view.endEditing(true)
            tableView.reloadData()
        } else {
            isSearching = true
            filteredData = vocabularies.filter {
              var retVal = $0.0.lowercased().contains(searchBar.text!.lowercased()) ||
              $0.1.lowercased().contains(searchBar.text!.lowercased())
              
              if let date = $0.addedDate {
                retVal = retVal || VocabularyDateFormatter.prettyDateFormatter.string(from: date).contains(searchBar.text!)
                }
              return retVal
            }
            
            tableView.reloadData()
        }
    }
    
    func loadDataAndUpdate() {
        
        guard  let language = selectedLanguage else {print("no language given"); return}
        if let vocab = UserDefaults.standard.dictionary(forKey: language) as? [String: String] {
            vocabDict = vocab
        } else {
            vocabDict = [String: String]()
        }
        
        guard let vocabProgress = UserDefaults.standard.dictionary(forKey: "\(language)Progress") as? [String: Float] else {
            print("no progresses found")
            showEmptyHint()
            return
        }
        vocabProgr = vocabProgress
        
        var vocabDates = [String: Date]()
        if let dates = UserDefaults.standard.dictionary(forKey: "\(language)DateAdded") as? [String: Date] {
            vocabDates = dates
        }
        
        vocabularies = [(word: String, translation: String, progress: Float, addedDate: Date?)]()
        for (key, value) in vocabDict {
            vocabularies.append((key, value, vocabProgress[key] ?? 100.0, vocabDates[key]))
        }
        
        filteredData = vocabularies.filter { $0.0.lowercased().contains(searchBar.text!.lowercased()) || $0.1.lowercased().contains(searchBar.text!.lowercased())            
        }
        
        UIView.transition(with: tableView, duration: 0.3, options: .transitionCrossDissolve, animations: {self.tableView.reloadData()}, completion: nil)
        
        totalProgress = vocabularies.reduce(0) { $0 + $1.2 }
        
        if let maxItem = vocabularies.max(by: {$0.2 < $1.2 }) {
            let max = maxItem.2
            print("max progress: \(max)")
            maxProgress = max
        }
        
        if vocabDict.isEmpty {
            showEmptyHint()
        } else {
            hideEmptyHint()
        }        
    }
    
    fileprivate func showEmptyHint() {
        sortWordButton.isHidden = true
        sortTranslationButton.isHidden = true
        sortDateButton.isHidden = true
        
        hintLabel.text = NSLocalizedString("Currently there are no words", comment: "Currently there are no words")
        hintLabel.isHidden = false
    }

    fileprivate func hideEmptyHint() {
        sortWordButton.isHidden = false
        sortTranslationButton.isHidden = false
        sortDateButton.isHidden = false
        
        hintLabel.isHidden = true
    }

    func convertToJSON(dic: NSDictionary) -> String? {
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
            // mail.setToRecipients(["m.steudter@gmx.de"])
            
            let export = ["vocabularies": vocabDict, "progresses": vocabProgr] as [String: Any]
            
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
        // sendEmail()
        // exportToDocuments()
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
    
    func exportToDocuments() {
        let export = ["vocabularies": vocabDict, "progresses": vocabProgr] as [String: Any]
        
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
            
            if !exportString.isEmpty {
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
            
            // writing
            do {
                try exportString.write(to: fileURL, atomically: false, encoding: .macOSRoman)
                
                let alert = UIAlertController(title: "\(NSLocalizedString("Export successful:", comment: "Export successful:")) \(language).csv", message: String.localizedStringWithFormat(NSLocalizedString("You may copy your file to your machine via iTunes:\n iPhone->Filesharing->Flippy->drag %@.csv into Finder", comment: "You may copy your file to your machine via iTunes:\n iPhone->Filesharing->Flippy->drag %@.csv into Finder"), language)
                                              , preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.cancel, handler: nil))
                self.present(alert, animated: true, completion: nil)
            } catch {/* error handling here */}
            
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
        
        infoText = NSLocalizedString("Swipe left to edit word (edit its probability or delete it)", comment: "Swipe left to edit word (edit its probability or delete it)")
    }
}

// MARK: UITableViewDataSource

extension LanguageScreenViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var result: Int
        
        if isSearching {
            result = filteredData.count
        } else {
            result = vocabularies.count
        }
        
        if vocabularies.isEmpty {
            searchBar.isHidden = true
            tableView.isHidden = true
            infoText = NSLocalizedString("ℹ️ Add new words with the button below", comment: "ℹ️ Add new words with the button below")
            view.layoutIfNeeded()
        } else {
            searchBar.isHidden = false
            tableView.isHidden = false
            
            infoText = NSLocalizedString("Swipe left to edit word (edit its probability or delete it)", comment: "Swipe left to edit word (edit its probability or delete it)")
            
            view.layoutIfNeeded()
        }
        
        return result
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier.vocabularyCell) as? VocabularyCell {
            
            print("totalProgress: \(totalProgress)")
            
            if isSearching {
                cell.vocabularyRoot.text = filteredData[indexPath.item].word
                cell.vocabularyTranslation.text = filteredData[indexPath.item].translation
                cell.vocabularyProgress.progress = filteredData[indexPath.item].progress/maxProgress
                
                if let date = filteredData[indexPath.item].addedDate {
                    cell.dateAddedLabel.text = VocabularyDateFormatter.prettyDateFormatter.string(from: date)
                } else {
                    cell.dateAddedLabel.text = ""
                }
            } else {
                cell.vocabularyRoot.text = vocabularies[indexPath.item].word
                cell.vocabularyTranslation.text = vocabularies[indexPath.item].translation
                cell.vocabularyProgress.progress = vocabularies[indexPath.item].progress/maxProgress
                
                if let date = vocabularies[indexPath.item].addedDate {
                    cell.dateAddedLabel.text = VocabularyDateFormatter.prettyDateFormatter.string(from: date)
                } else {
                    cell.dateAddedLabel.text = ""
                }
            }
            
            return cell
        }
        return UITableViewCell()
    }
}

// MARK: UITableViewDelegate

extension LanguageScreenViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool { true }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = makeDeleteContextualAction(tableView: tableView, indexPath: indexPath)
        let editProbabilityAction = makeEditProbabilityContextualAction(tableView: tableView, indexPath: indexPath)
        let editWordAction = makeEditWordContextualAction(tableView: tableView, indexPath: indexPath)
        return UISwipeActionsConfiguration(actions: [deleteAction, editProbabilityAction, editWordAction])
    }
    
    private func makeDeleteContextualAction(tableView: UITableView, indexPath: IndexPath) -> UIContextualAction {
        UIContextualAction(style: .destructive, title: NSLocalizedString("Delete", comment: "Delete")) { [weak self] (_, _, _) in
            guard let self = self else { return print("Action did run when view controller is already deallocated") }
            guard let cell = tableView.cellForRow(at: indexPath) as? VocabularyCell,
                  let key = cell.vocabularyRoot.text else { return print("Cell is configured incorrect or not found") }
            print(self.vocabDict)
            
            self.vocabDict.removeValue(forKey: key)
            self.vocabProgr.removeValue(forKey: key)
            print("Deleted \(key)")
            
            guard let language = self.selectedLanguage else { return print("No language selected") }
            
            UserDefaults.standard.set(self.vocabDict, forKey: language)
            UserDefaults.standard.set(self.vocabProgr, forKey: "\(language)Progress")
            
            self.loadDataAndUpdate()
        }
    }
    
    private func makeEditProbabilityContextualAction(tableView: UITableView, indexPath: IndexPath) -> UIContextualAction {
        let title = "\(NSLocalizedString("Edit:", comment: "Edit:")) \(Int(vocabularies[indexPath.item].2))/\(Int(maxProgress))"
        let editProbabilityAction = UIContextualAction(style: .normal, title: title) { [weak self] (_, _, _) in
            guard let self = self else { return print("Action did run when view controller is already deallocated") }
            guard let cell = tableView.cellForRow(at: indexPath) as? VocabularyCell,
                  let key = cell.vocabularyRoot.text else { return print("Cell is configured incorrect or not found") }
            guard let language = self.selectedLanguage else { return print("No language selected") }
            
            let title = NSLocalizedString("Change word`s probability", comment: "Change word`s probability")
            let message = NSLocalizedString("Change word`s probability value. Higher value -> higher probability for word to appear.\nNew words start with 100.", comment: "Change word`s probability value. Higher value -> higher probability for word to appear.\nNew words start with 100.")
            let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
            
            alertController.addTextField { (textField) in
                guard let progress = self.vocabProgr[key] else { return print("No progress found") }
                textField.text = "\(Int.init(progress))"
            }
            
            alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alertController] _ in
                guard let textField = alertController?.textFields?.first,
                      let inputText = textField.text else { return print("Input text is missing")}
                print("Textfield text: \(inputText)")
                
                self.vocabProgr[key] = max((inputText as NSString).floatValue, 1)
                
                UserDefaults.standard.set(self.vocabProgr, forKey: "\(language)Progress")
                
                self.loadDataAndUpdate()
                tableView.reloadData()
            }))
            
            alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel) { _ in })
            self.present(alertController, animated: UIView.areAnimationsEnabled)
        }
        editProbabilityAction.backgroundColor = BackgroundColor.fullBlue
        return editProbabilityAction
    }
    
    private func makeEditWordContextualAction(tableView: UITableView, indexPath: IndexPath) -> UIContextualAction {
        let title = NSLocalizedString("Edit word", comment: "Edit word")
        let editWordAction = UIContextualAction(style: .normal, title: title) { [weak self] (_, _, _) in
            guard let self = self else { return print("Action did run when view controller is already deallocated") }
            guard let cell = tableView.cellForRow(at: indexPath) as? VocabularyCell,
                  let word = cell.vocabularyRoot.text else { return print("Cell is configured incorrect or not found") }
            guard let translation = self.vocabDict[word],
                  let progress = self.vocabProgr[word] else { return print("Current word is missing in data source") }
            guard let language = self.selectedLanguage else { return print("No language selected") }
            
            let message = NSLocalizedString("Your progress and probability configuration for this word will be saved",
                                            comment: "Your progress and probability configuration for this word will be saved")
            let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
            
            alertController.addTextField { (textField) in textField.text = word }
            alertController.addTextField { (textField) in textField.text = translation }
            
            alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alertController] _ in
                guard let wordTextField = alertController?.textFields?.first,
                      let newWord = wordTextField.text else { return print("New word text is missing") }
                guard let translationTextField = alertController?.textFields?.last,
                      let newTranslation = translationTextField.text else { return print("Translation text is missing") }
                
                // Update data source
                self.vocabDict.removeValue(forKey: word)
                self.vocabProgr.removeValue(forKey: word)
                
                self.vocabDict[newWord] = newTranslation
                self.vocabProgr[newWord] = progress
                
                // Save edit data to user defaults
                UserDefaults.standard.set(self.vocabDict, forKey: language)
                UserDefaults.standard.set(self.vocabProgr, forKey: "\(language)Progress")
                
                // Reload table view
                self.loadDataAndUpdate()
                tableView.reloadData()
            }))
            
            alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel) { _ in })
            self.present(alertController, animated: UIView.areAnimationsEnabled)
        }
        editWordAction.backgroundColor = BackgroundColor.lightGreen
        return editWordAction
    }
}
