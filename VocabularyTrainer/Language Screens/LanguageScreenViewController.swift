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
    
    let buttonHeight: CGFloat = 36
    let symbolConfig = UIImage.SymbolConfiguration(textStyle: .title1, scale: .large)

    lazy var backButton: UIButton = {
        let button: UIButton = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.heightAnchor.constraint(equalToConstant: buttonHeight).isActive = true
        button.setTitle(NSLocalizedString("< Back", comment: "< Back"), for: .normal)
        button.backgroundColor = BackgroundColor.hansaYellow
        button.layer.cornerRadius = 5.0
        button.contentEdgeInsets = UIEdgeInsets.init(top: 0, left: 10, bottom: 0, right: 10)
        button.setTitleColor(BackgroundColor.japaneseIndigo, for: .normal)
        return button
    }()
    
    lazy var deleteButton: UIButton = {
        let button: UIButton = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.heightAnchor.constraint(equalToConstant: buttonHeight).isActive = true
        button.setTitle(NSLocalizedString("Delete Language", comment: "Delete Language"), for: .normal)
        button.backgroundColor = BackgroundColor.red
        button.layer.cornerRadius = 5.0
        button.contentEdgeInsets = UIEdgeInsets.init(top: 0, left: 10, bottom: 0, right: 10)
        button.setTitleColor(BackgroundColor.mediumWhite, for: .normal)
        return button
    }()
    
    lazy var searchBar: UISearchBar = {
        let searchBar: UISearchBar = UISearchBar()
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        searchBar.tintColor = UIColor(white: 1.0, alpha: 0.3)
        return searchBar
    }()
    
    lazy var tableView: UITableView = {
        let tableView = UITableView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = UIColor(white: 1.0, alpha: 0.3)
        tableView.layer.cornerRadius = 10.0
        return tableView
    }()
    
    lazy var newWordButton: UIButton = {
        let button: UIButton = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.titleLabel?.font = .systemFont(ofSize: 25)
        button.setTitle(NSLocalizedString("New Word", comment: "New Word"), for: .normal)
        button.backgroundColor = BackgroundColor.mediumSpringBud
        button.layer.cornerRadius = 5.0
        button.setTitleColor(BackgroundColor.japaneseIndigo, for: .normal)
        return button
    }()
    
    lazy var hintLabel: UILabel = {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 17)
        return label
    }()
    
    lazy var exportButton: UIButton = {
        let button: UIButton = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.titleLabel?.text = NSLocalizedString("⤴ export", comment: "⤴ export")
        button.setTitleColor(BackgroundColor.japaneseIndigo, for: .normal)
        button.backgroundColor = UIColor(white: 1.0, alpha: 0.3)
        button.layer.cornerRadius = 5.0
        button.contentEdgeInsets = UIEdgeInsets(top: 4.0, left: 4.0, bottom: 4.0, right: 4.0)
        return button
    }()
    
    lazy var languageHeader: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = NSLocalizedString("Language", comment: "Language")
        label.font = .systemFont(ofSize: 32)
        return label
    }()
    
    lazy var infoButton: UIButton = {
        let button: UIButton = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(
            UIImage(
                systemName: "info.circle.fill",
                withConfiguration: symbolConfig
            ),
            for: .normal
        )
        button.sizeToFit()
        button.setTitleColor(.white, for: .normal)
        button.tintColor = .white
        return button
    }()
    
    lazy var sortWordButton: UIButton = {
        let button: UIButton = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)
        button.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        button.setImage(
            UIImage(
                systemName: "chevron.up.square.fill",
                withConfiguration: symbolConfig
            ),
            for: .normal
        )
        button.sizeToFit()
        button.setTitleColor(.blue, for: .normal)
        button.tintColor = .white
        return button
    }()
    
    lazy var sortTranslationButton: UIButton = {
        let button: UIButton = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(
            UIImage(
                systemName: "minus.square.fill",
                withConfiguration: symbolConfig
            ),
            for: .normal
        )
        button.sizeToFit()
        button.setTitleColor(.blue, for: .normal)
        button.tintColor = .white
        return button
    }()
    
    lazy var sortDateButton: UIButton = {
        let button: UIButton = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)
        button.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        button.setImage(
            UIImage(
                systemName: "minus.square.fill",
                withConfiguration: symbolConfig
            ),
            for: .normal
        )
        button.setTitleColor(.blue, for: .normal)
        button.tintColor = .white
        return button
    }()
    
    
    var selectedLanguage: String?
    var vocabularies = [(word: String, translation: String, progress: Float, addedDate: Date?)]()
    var vocabDict = [String:String]()
    var vocabProgr = [String:Float]()
    var filteredData = [(word: String, translation: String, progress: Float, addedDate: Date?)]()
    var isSearching = false
    var totalProgress = Float(0)
    var maxProgress = Float(0)
    var completed: (()->Void)?
    
    /// Sorting directions for the vocabulary list.
    var isSortingAscending = (word: false, translation: false, date: false)
    
    /// The info text that will appear when tapping on the info button.
    var infoText = ""
    
    enum SortElement {
        case word
        case translation
        case date
    }
    
    var delegate: NewLanguageScreenProtocol? = nil
    
    override func loadView() {
        super.loadView()
        setUpLayout()
        hookButtonActions()
    }
    
    func setUpLayout() {
        view.backgroundColor = .systemTeal
        view.addSubview(tableView)
        view.addSubview(backButton)
        view.addSubview(deleteButton)
        view.addSubview(searchBar)
        view.addSubview(languageHeader)
        view.addSubview(exportButton)
        view.addSubview(hintLabel)
        view.addSubview(infoButton)
        view.addSubview(newWordButton)
        view.addSubview(sortDateButton)
        view.addSubview(sortWordButton)
        view.addSubview(sortTranslationButton)
        NSLayoutConstraint.activate([
            // constraints for back button.
            NSLayoutConstraint(
                item: backButton,
                attribute: .leading,
                relatedBy: .equal,
                toItem: view.safeAreaLayoutGuide,
                attribute: .leading,
                multiplier: 1,
                constant: 16
            ),
            NSLayoutConstraint(
                item: backButton,
                attribute: .top,
                relatedBy: .equal,
                toItem: view.safeAreaLayoutGuide,
                attribute: .top,
                multiplier: 1,
                constant: 16
            ),
            NSLayoutConstraint(
                item: backButton,
                attribute: .bottom,
                relatedBy: .equal,
                toItem: languageHeader,
                attribute: .top,
                multiplier: 1,
                constant: -16
            ),
            // constraints for delete button.
            NSLayoutConstraint(
                item: deleteButton,
                attribute: .top,
                relatedBy: .equal,
                toItem: view.safeAreaLayoutGuide,
                attribute: .top,
                multiplier: 1,
                constant: 16
            ),
            NSLayoutConstraint(
                item: view.safeAreaLayoutGuide,
                attribute: .trailing,
                relatedBy: .equal,
                toItem: deleteButton,
                attribute: .trailing,
                multiplier: 1,
                constant: 16
            ),
            // constraints for language label.
            NSLayoutConstraint(
                item: languageHeader,
                attribute: .top,
                relatedBy: .equal,
                toItem: backButton,
                attribute: .bottom,
                multiplier: 1,
                constant: 16
            ),
            NSLayoutConstraint(
                item: languageHeader,
                attribute: .centerX,
                relatedBy: .equal,
                toItem: view,
                attribute: .centerX,
                multiplier: 1,
                constant: 0
            ),
            NSLayoutConstraint(
                item: exportButton,
                attribute: .centerX,
                relatedBy: .equal,
                toItem: languageHeader,
                attribute: .centerX,
                multiplier: 1,
                constant: 0
            ),
            // constraints for searchBar.
            NSLayoutConstraint(
                item: searchBar,
                attribute: .top,
                relatedBy: .equal,
                toItem: languageHeader,
                attribute: .bottom,
                multiplier: 1,
                constant: 4
            ),
            NSLayoutConstraint(
                item: searchBar,
                attribute: .top,
                relatedBy: .equal,
                toItem: exportButton,
                attribute: .bottom,
                multiplier: 1,
                constant: 8
            ),
            NSLayoutConstraint(
                item: searchBar,
                attribute: .top,
                relatedBy: .equal,
                toItem: infoButton,
                attribute: .bottom,
                multiplier: 1,
                constant: 8
            ),
            NSLayoutConstraint(
                item: searchBar,
                attribute: .leading,
                relatedBy: .equal,
                toItem: view.safeAreaLayoutGuide,
                attribute: .leading,
                multiplier: 1,
                constant: 16
            ),
            NSLayoutConstraint(
                item: view.safeAreaLayoutGuide,
                attribute: .trailing,
                relatedBy: .equal,
                toItem: searchBar,
                attribute: .trailing,
                multiplier: 1,
                constant: 16
            ),
            // constraints for sortWord Button.
            NSLayoutConstraint(
                item: sortWordButton,
                attribute: .leading,
                relatedBy: .equal,
                toItem: tableView,
                attribute: .leading,
                multiplier: 1,
                constant: 16
            ),
            NSLayoutConstraint(
                item: sortWordButton,
                attribute: .top,
                relatedBy: .equal,
                toItem: searchBar,
                attribute: .bottom,
                multiplier: 1,
                constant: 8
            ),
            NSLayoutConstraint(
                item: tableView,
                attribute: .top,
                relatedBy: .equal,
                toItem: sortWordButton,
                attribute: .bottom,
                multiplier: 1,
                constant: 8
            ),
            // constraints for sortTranslation button.
            NSLayoutConstraint(
                item: sortTranslationButton,
                attribute: .top,
                relatedBy: .equal,
                toItem: searchBar,
                attribute: .bottom,
                multiplier: 1,
                constant: 8
            ),
            NSLayoutConstraint(
                item: sortTranslationButton,
                attribute: .centerX,
                relatedBy: .equal,
                toItem: tableView,
                attribute: .centerX,
                multiplier: 1,
                constant: 0
            ),
            NSLayoutConstraint(
                item: tableView,
                attribute: .top,
                relatedBy: .equal,
                toItem: sortTranslationButton,
                attribute: .bottom,
                multiplier: 1,
                constant: 8
            ),
            // constraints for sortDate button.
            NSLayoutConstraint(
                item: sortDateButton,
                attribute: .trailing,
                relatedBy: .equal,
                toItem: tableView,
                attribute: .trailing,
                multiplier: 1,
                constant: -16
            ),
            NSLayoutConstraint(
                item: sortWordButton,
                attribute: .top,
                relatedBy: .equal,
                toItem: searchBar,
                attribute: .bottom,
                multiplier: 1,
                constant: 8
            ),
            NSLayoutConstraint(
                item: tableView,
                attribute: .top,
                relatedBy: .equal,
                toItem: sortDateButton,
                attribute: .bottom,
                multiplier: 1,
                constant: 8
            ),
            // constraints for tableView button.
            NSLayoutConstraint(
                item: tableView,
                attribute: .leading,
                relatedBy: .equal,
                toItem: view.safeAreaLayoutGuide,
                attribute: .leading,
                multiplier: 1,
                constant: 16
            ),
            NSLayoutConstraint(
                item: view.safeAreaLayoutGuide,
                attribute: .trailing,
                relatedBy: .equal,
                toItem: tableView,
                attribute: .trailing,
                multiplier: 1,
                constant: 16
            ),
            NSLayoutConstraint(
                item: newWordButton,
                attribute: .top,
                relatedBy: .equal,
                toItem: tableView,
                attribute: .bottom,
                multiplier: 1,
                constant: 16
            ),
            //constraints for newWord button.
            NSLayoutConstraint(
                item: newWordButton,
                attribute: .leading,
                relatedBy: .equal,
                toItem: view.safeAreaLayoutGuide,
                attribute: .leading,
                multiplier: 1,
                constant: 32
            ),
            NSLayoutConstraint(
                item: view.safeAreaLayoutGuide,
                attribute: .trailing,
                relatedBy: .equal,
                toItem: newWordButton,
                attribute: .trailing,
                multiplier: 1,
                constant: 32
            ),
            NSLayoutConstraint(
                item: view.safeAreaLayoutGuide,
                attribute: .bottom,
                relatedBy: .equal,
                toItem: newWordButton,
                attribute: .bottom,
                multiplier: 1,
                constant: 16
            ),
            //constraints for hintLabel.
            NSLayoutConstraint(
                item: hintLabel,
                attribute: .leading,
                relatedBy: .lessThanOrEqual,
                toItem: view.safeAreaLayoutGuide,
                attribute: .leading,
                multiplier: 1,
                constant: 20
            ),
            NSLayoutConstraint(
                item: view.safeAreaLayoutGuide,
                attribute: .trailing,
                relatedBy: .greaterThanOrEqual,
                toItem: hintLabel,
                attribute: .trailing,
                multiplier: 1,
                constant: 20
            ),
            NSLayoutConstraint(
                item: hintLabel,
                attribute: .centerX,
                relatedBy: .equal,
                toItem: view.safeAreaLayoutGuide,
                attribute: .centerX,
                multiplier: 1,
                constant: 0
            ),
            NSLayoutConstraint(
                item: hintLabel,
                attribute: .centerY,
                relatedBy: .equal,
                toItem: view.safeAreaLayoutGuide,
                attribute: .centerY,
                multiplier: 1,
                constant: 0
            ),
            NSLayoutConstraint(
                item: infoButton,
                attribute: .leading,
                relatedBy: .equal,
                toItem: view.safeAreaLayoutGuide,
                attribute: .leading,
                multiplier: 1,
                constant: 16
            ),
            NSLayoutConstraint(
                item: searchBar,
                attribute: .top,
                relatedBy: .equal,
                toItem: infoButton,
                attribute: .bottom,
                multiplier: 1,
                constant: 8
            )
        ])
        
        //TechDebt: Don't know why we have a export button here when it was not unhidden before
        exportButton.isHidden = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        tableView.register(VocabularyCell.self, forCellReuseIdentifier: CellIdentifier.vocabularyCell)
        
        tableView.delegate = self
        tableView.dataSource = self
        searchBar.delegate = self
        
        guard let language = selectedLanguage else {return}
        languageHeader.text = language
        hideKeyboardWhenTappedAround()
        
        searchBar.layer.cornerRadius = 10.0
        searchBar.layer.borderWidth = 0.0
        searchBar.clipsToBounds = true
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
    
    func hookButtonActions() {
        backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        
        deleteButton.addTarget(self, action: #selector(deleteButtonTapped), for: .touchUpInside)
        
        infoButton.addTarget(self, action: #selector(infoButtonTapped), for: .touchUpInside)
        
        sortWordButton.addTarget(self, action: #selector(sortButtonTapped), for: .touchUpInside)
        sortTranslationButton.addTarget(self, action: #selector(sortButtonTapped), for: .touchUpInside)
        sortDateButton.addTarget(self, action: #selector(sortButtonTapped), for: .touchUpInside)
        
        exportButton.addTarget(self, action: #selector(exportButtonTapped), for: .touchUpInside)
        newWordButton.addTarget(self, action: #selector(addNewWordTapped), for: .touchUpInside)
    }
    
    @objc func backButtonTapped(_ sender: Any) {
        completed?()
        dismiss(animated: true, completion: nil)
    }
    
    @objc func addNewWordTapped(_ sender: Any) {
        let viewController = AddNewWordViewController(selectedLanguage: selectedLanguage)
        self.present(viewController, animated: true)
    }
    
    @objc func deleteButtonTapped(_ sender: Any) {
        
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
    
    @objc func infoButtonTapped(_ sender: Any) {
        let alert = UIAlertController(title: nil,
                                      message: infoText,
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: "Cancel"),
                                      style: .cancel,
                                      handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
   @objc func sortButtonTapped(_ sender: UIButton) {
       
       let chevronUpImage = UIImage(systemName: "chevron.up.square.fill", withConfiguration: symbolConfig)
       let chevronDownImage = UIImage(systemName: "chevron.down.square.fill", withConfiguration: symbolConfig)
       let minusImage = UIImage(systemName: "minus.square.fill", withConfiguration: symbolConfig)
       
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
    
    @objc func exportButtonTapped(_ sender: Any) {
        //sendEmail()
        //exportToDocuments()
        exportAsCsvToDocuments()
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
    
    
    func loadVocabulary()->[String:String] {
        guard let language = selectedLanguage else {print("language not given"); return [String:String]()}
        
        guard let vocabulary = UserDefaults.standard.dictionary(forKey: language) as? [String:String] else {print("wrong dictionary format/not found"); return [String:String]()}
        return vocabulary
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text == nil || searchBar.text == "" {
            isSearching = false
            view.endEditing(true)
            tableView.reloadData()
        } else {
            isSearching = true
            filteredData = vocabularies.filter(
                {
                    var retVal = $0.0.lowercased().contains(searchBar.text!.lowercased()) ||
                    $0.1.lowercased().contains(searchBar.text!.lowercased())
                    if let date = $0.addedDate {
                        retVal = retVal || VocabularyDateFormatter.prettyDateFormatter.string(from: date).contains(searchBar.text!)
                    }
                    return retVal
                })
            tableView.reloadData()
            
        }
    }
    
    func loadDataAndUpdate() {
        
        guard  let language = selectedLanguage else {print("no language given"); return}
        if let vocab = UserDefaults.standard.dictionary(forKey: language) as? [String:String] {
            vocabDict = vocab
        } else {
            vocabDict = [String:String]()
        }
        
        guard let vocabProgress = UserDefaults.standard.dictionary(forKey: "\(language)Progress") as? [String:Float] else {
            print("no progresses found")
            showEmptyHint()
            return
        }
        vocabProgr = vocabProgress
        
        var vocabDates = [String: Date]()
        if let dates = UserDefaults.standard.dictionary(forKey: "\(language)DateAdded") as? [String:Date] {
            vocabDates = dates
        }
        
        vocabularies = [(word: String, translation: String, progress: Float, addedDate: Date?)]()
        for (key, value) in vocabDict {
            vocabularies.append((key, value, vocabProgress[key] ?? 100.0, vocabDates[key]))
        }
        
        filteredData = vocabularies.filter({ $0.0.lowercased().contains(searchBar.text!.lowercased()) || $0.1.lowercased().contains(searchBar.text!.lowercased())})
        
        UIView.transition(with: tableView, duration: 0.3, options: .transitionCrossDissolve, animations: {self.tableView.reloadData()}, completion: nil)
        
        totalProgress = vocabularies.reduce(0){$0 + $1.2}
        
        if let maxItem = vocabularies.max(by: {$0.2 < $1.2 }) {
            let max = maxItem.2
            print("max progress: \(max)")
            maxProgress = max
        }
        
        vocabDict.isEmpty ? showEmptyHint() : hideEmptyHint()
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
        
        infoText = NSLocalizedString("Swipe left to edit word (edit its probability or delete it)", comment: "Swipe left to edit word (edit its probability or delete it)")
    }
    
}


extension LanguageScreenViewController: UITableViewDataSource {
    
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
