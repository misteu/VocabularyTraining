//
//  ViewController.swift
//  VocabularyTrainer
//
//  Created by skrr on 10.03.19.
//  Copyright © 2019 mic. All rights reserved.
//

import UIKit
import WebKit

protocol NewLanguageScreenProtocol: AnyObject {
  func updateLanguageTable(language: String)
}

struct LanguageImport {
  var vocabularies: [String: String]
  var progresses: [String: Float]
  var datesAdded = [String: Date]()
  
  init(vocabularies: [String: String],
       progresses: [String: Float],
       datesAdded: [String: Date]) {
    self.vocabularies = vocabularies
    self.progresses = progresses
    self.datesAdded = datesAdded
  }
}

final class HomeScreenViewController: UIViewController, NewLanguageScreenProtocol {
  var topButtons: [UIButton] = []
  
  var addLanguageButton = UIButton()
  
  var headerTextConstraintTop: NSLayoutConstraint?
  var headerText = UILabel()
  var importButton = UIButton()
  var exportButton = UIButton()
  var aboutAppButton = UIButton()

  var tableView = UITableView()
  private let refreshControl = UIRefreshControl()

  let defaults = UserDefaults.standard
  
  var languages = [String]()
  var selectedRow: Int?

  private var loadingController: UIAlertController?
  let webView = WKWebView()
  let webViewVC = UIViewController()
  var coordinator: MainCoordinator?

  var selectedLanguage = ""

  // MARK: - Init

  init() {
    super.init(nibName: nil, bundle: nil)
  }

  required init?(coder: NSCoder) { nil }

  // MARK: - View Lifecycle

  override func viewDidLoad() {
    super.viewDidLoad()
    webView.navigationDelegate = self
    for button in topButtons {
      button.isHidden = true
      button.alpha = 0.0
      button.layer.cornerRadius = 5.0
      button.setTitleColor(.black, for: .normal)
      button.contentEdgeInsets = UIEdgeInsets.init(top: 0, left: 10, bottom: 0, right: 10)
    }
    
    styleUi()
    localize()
    headerTextConstraintTop?.constant = 32.0
    tableView.delegate = self
    tableView.dataSource = self
    
    guard let rows = defaults.array(forKey: UserDefaultKeys.languages)?.count else { return}
    debugPrint("rows \(rows)")
    
    if let languages = defaults.array(forKey: UserDefaultKeys.languages) as? [String] {
      self.languages = languages
    }
    
    hideKeyboardWhenTappedAround()

    debugPrint("[DEBUG] Language file URLS: \(ExportImport.getAllLanguageFileUrls().debugDescription)")
  }

  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    if !languages.isEmpty {
      DispatchQueue.main.async {
        self.view.viewWithTag(99)?.removeFromSuperview()
      }
    }
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(true)
    _ = checkNumberOfLanguages()
    
    if let languages = defaults.array(forKey: UserDefaultKeys.languages) as? [String] {
      self.languages = languages
    }
    tableView.reloadData()
    setGradientBackground(view: view)
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(true)
    if !languages.isEmpty {
      view.viewWithTag(99)?.removeFromSuperview()
    }
  }

  // MARK: - Internal Methods

  func updateLanguageTable(language: String) {
    debugPrint("\(language) added/deleted")
    tableView.reloadData()

    if let languages = defaults.array(forKey: UserDefaultKeys.languages) as? [String] {
      self.languages = languages
    }
  }

  // MARK: - Private Methods

  fileprivate func showNoLanguagesLabel() {
    //    let noLanguagesLabel = UILabel(frame: CGRect(x: 20, y: importButton.frame.maxY, width: view.frame.width-40, height: tableView.frame.height))
    let noLanguagesLabel = UILabel()
    view.addSubview(noLanguagesLabel)
    
    noLanguagesLabel.text = NSLocalizedString("Currently there are no languages", comment: "Currently there are no languages")
    noLanguagesLabel.textAlignment = .center
    noLanguagesLabel.numberOfLines = 0
    noLanguagesLabel.tag = 99
    noLanguagesLabel.translatesAutoresizingMaskIntoConstraints = false
    
    NSLayoutConstraint.activate([
      noLanguagesLabel.topAnchor.constraint(equalTo: tableView.topAnchor, constant: 20.0),
      noLanguagesLabel.leftAnchor.constraint(equalTo: tableView.leftAnchor, constant: 20.0),
      noLanguagesLabel.rightAnchor.constraint(equalTo: tableView.rightAnchor, constant: -20.0)
    ])
  }
  
  private func checkNumberOfLanguages() -> Int {
    guard let rows = defaults.array(forKey: UserDefaultKeys.languages)?.count else {
      showNoLanguagesLabel()
      return 0
    }
    if rows < 1 {
      showNoLanguagesLabel()
    } else {
      view.viewWithTag(99)?.removeFromSuperview()
    }
    return rows
  }

  @IBAction func trainingButton(_ sender: Any) {
    deactivateTopButtons()
    
    guard let row = selectedRow else {debugPrint("nothing selected"); return}
    selectedLanguage = languages[row]
    
    if areWordsSavedFor(language: selectedLanguage) {
        coordinator?.navigateToTrainingViewController(with: selectedLanguage)
    } else {
      showToast(message: NSLocalizedString("No words inside 🕵️‍♀️", comment: "No words inside 🕵️‍♀️"), yCoord: view.frame.maxY/2)
    }
    
  }
  @IBAction func editButton(_ sender: Any) {
    
    deactivateTopButtons()
    
    guard let row = selectedRow else {debugPrint("nothing selected"); return}
    
    selectedLanguage = languages[row]
      coordinator?.navigateToLanguageScreenViewController(selectedLanguage: selectedLanguage, newLanguageScreenProtocol: self, completion: { [weak self] in
            self?.tableView.reloadData()
          
      })
  }
  
  func deactivateTopButtons() {
    self.headerTextConstraintTop?.constant = 16.0
    UIView.animate(withDuration: 0.2, animations: {
      self.view.layoutIfNeeded()
      for button in self.topButtons {
        button.alpha = 0.0
      }
    }, completion: {_ in
      for button in self.topButtons {
        button.isHidden = true
      }
    })
  }
  
  func areWordsSavedFor(language: String) -> Bool {
      
    if UserDefaults.standard.dictionary(forKey: language) == nil {
        debugPrint("no vocabularies found")
        return false
    } else {
        return true
    }      
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
    
    exportButton.setTitleColor(BackgroundColor.japaneseIndigo, for: .normal)
    exportButton.backgroundColor = UIColor(white: 1.0, alpha: 0.3)
    exportButton.layer.cornerRadius = 5.0
    exportButton.contentEdgeInsets = UIEdgeInsets(top: 4.0, left: 4.0, bottom: 4.0, right: 4.0)
    
    tableView.backgroundColor = UIColor(white: 1.0, alpha: 0.3)
    tableView.layer.cornerRadius = 10.0
    
    aboutAppButton.setTitleColor(.white, for: .normal)
    
  }
  
  func localize() {
    headerText.text = NSLocalizedString("Your Languages", comment: "Your Languages")
    addLanguageButton.setTitle(NSLocalizedString("Add language", comment: "Add language"), for: .normal)
    
    topButtons[0].setTitle(NSLocalizedString("Training", comment: "Training"), for: .normal)
    topButtons[1].setTitle(NSLocalizedString("My words", comment: "settings"), for: .normal)
    importButton.setTitle(NSLocalizedString("⤵ import", comment: "⤵ import"), for: .normal)
    exportButton.setTitle(NSLocalizedString("↑ export", comment: "↑ export"), for: .normal)
    aboutAppButton.setTitle(NSLocalizedString("About Flippy App", comment: "About Flippy App"), for: .normal)
  }
  
  func spinner(start: Bool) {
    let spinner = UIActivityIndicatorView(style: .large)
    if start {
      spinner.startAnimating()
      spinner.tag = 123
      tableView.backgroundView = spinner
    } else {
      guard let spinner = tableView.viewWithTag(123) as? UIActivityIndicatorView else { return }
      spinner.stopAnimating()
    }
    
  }

  private func loadLocalPp(_ webView: WKWebView) {
    guard let htmlFile = Bundle.main.path(forResource: "pp", ofType: "html") else { return }
    guard let html = try? String(contentsOfFile: htmlFile, encoding: String.Encoding.utf8) else { return }
    webView.loadHTMLString(html, baseURL: nil)
  }

  private func showLoadingIndicator() {
    // Loading indicator
    loadingController = UIAlertController(title: nil,
                                          message: NSLocalizedString("Please wait...",
                                                                     comment: "Message on loading indicator"),
                                          preferredStyle: .alert)
    if let loadingController = loadingController {
      loadingController.view.tintColor = .black
      let loadingIndicator: UIActivityIndicatorView = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50)) as UIActivityIndicatorView
      loadingIndicator.hidesWhenStopped = true
      loadingIndicator.style = .medium
      loadingIndicator.startAnimating()
      
      loadingController.view.addSubview(loadingIndicator)
      present(loadingController, animated: true, completion: nil)
    }
  }
  
}

extension HomeScreenViewController: WKNavigationDelegate {
  func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
    dismiss(animated: true) {
      self.present(self.webViewVC, animated: true) {
        webView.scrollView.setContentOffset(CGPoint(x: 0, y: webView.safeAreaInsets.top), animated: true)
      }
    }
  }
}

// MARK: - Button Actions

extension HomeScreenViewController {

  // MARK: - Import

  @objc func reloadImports() {

    guard let files = ExportImport.getAllLanguageFileUrls() else { return }

    if files.isEmpty {
      let message = """
        There were not found any language files for your app.\nFor a template of a language file you may create a new language with some vocabulary inside this app and export it.
      """
      let alert = UIAlertController(
        title: NSLocalizedString("No language files found",
                                 comment: "No language files found"),
        message: NSLocalizedString(message, comment: message),
        preferredStyle: UIAlertController.Style.alert)

      alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.cancel, handler: nil))
      self.present(alert, animated: true, completion: nil)
    } else {
      view.viewWithTag(99)?.removeFromSuperview()
      ExportImport.importLanguageFiles(files)
      if let languages = UserDefaults.standard.array(forKey: UserDefaultKeys.languages) as? [String] {
        self.languages = languages
      }

      tableView.reloadData()
      self.refreshControl.endRefreshing()
      self.view.layoutIfNeeded()

      if tableView.numberOfRows(inSection: tableView.numberOfSections-1) > 0 {
        view.viewWithTag(99)?.removeFromSuperview()
      }
    }
  }

  // TODO: - Not sure what that is for, might be removed
//  @objc func tappedImportButton(_ sender: Any) {
//    spinner(start: true)
//
//    if !languages.isEmpty {
//
//      let message = """
//        Importing language files into the app will overwrite any languages in your app with the same name as the csv-file.\n Do you want to proceed?
//      """
//
//      let alert = UIAlertController(
//        title: NSLocalizedString("Importing language files",
//                                 comment: "Importing language files"),
//        message: NSLocalizedString(message, comment: message),
//        preferredStyle: UIAlertController.Style.alert)
//
//      // add the actions (buttons)
//      alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: "Cancel"), style: UIAlertAction.Style.cancel, handler: { _ in
//        self.spinner(start: false)
//      }))
//      alert.addAction(UIAlertAction(title: NSLocalizedString("Import", comment: "Import"), style: UIAlertAction.Style.destructive, handler: { _ in
//
//        self.reloadImports()
//        _ = Timer.scheduledTimer(withTimeInterval: 0.4, repeats: false, block: {_ in self.spinner(start: false)})
//
//      }))
//      self.present(alert, animated: true, completion: nil)
//    } else {
//      self.reloadImports()
//      _ = Timer.scheduledTimer(withTimeInterval: 0.4, repeats: false, block: {_ in self.spinner(start: false)})
//    }
//
//  }

  // MARK: - Export

  @objc func tappedExportButton(_ sender: Any) {
    if let selectedRow = selectedRow {
      debugPrint(languages[selectedRow])
      //    for language in languages {
      //      ExportImport.exportAsCsvToDocuments(language: language)
      //    }

      //    let alert = UIAlertController(title: "\(NSLocalizedString("Exported the following languages:", comment: "Exported the following languages:"))", message: "\(languages.joined(separator: ", ")) \n\n\(NSLocalizedString("You may copy your file to your machine via iTunes:\n iPhone->Filesharing->Flippy->drag csv-files into Finder", comment: "You may copy your file to your machine via iTunes:\n iPhone->Filesharing->Flippy->drag csv-files into Finder"))"
      //      , preferredStyle: UIAlertController.Style.alert)
      //    alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.cancel, handler: nil))
      //    self.present(alert, animated: true, completion: nil)

      let words = ExportImport.exportAsCsvToDocuments(language: languages[selectedRow])
      let ac = UIActivityViewController(activityItems: [words], applicationActivities: nil)
      present(ac, animated: true)
      self.selectedRow = nil
      tableView.deselectRow(at: IndexPath(row: selectedRow, section: 0), animated: true)
    } else {
      let alert = UIAlertController(title: NSLocalizedString("No language selected",
                                                             comment: "Title for popup when no language was selected"),
                                    message: NSLocalizedString("Please select a language to export first.", comment: "Text for no-language-selected popup."),
                                    preferredStyle: .alert)
      alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
      present(alert, animated: true, completion: nil)
    }
  }

  // MARK: - About
  // TODO: - Refactor this, create some UIViewController subclass for the webview.
  @objc func tappedAboutApp(_ sender: Any) {
    let closeButton = UIButton()
    closeButton.translatesAutoresizingMaskIntoConstraints = false
    closeButton.backgroundColor = BackgroundColor.hansaYellow
    closeButton.setTitle(NSLocalizedString("Close", comment: "Close"), for: .normal)
    closeButton.addTarget(self, action: #selector(tappedClose), for: .touchUpInside)
    closeButton.setTitleColor(.black, for: .normal)

    let versionLabel = UILabel()
    let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
    versionLabel.text = "FlippyLearn Version: \(appVersion ?? "unknown")"
    versionLabel.translatesAutoresizingMaskIntoConstraints = false
    versionLabel.textAlignment = .center
    versionLabel.backgroundColor = BackgroundColor.hansaYellow

    // view below label making it nicer for devices without home button
    let bottomView = UIView()
    bottomView.backgroundColor = BackgroundColor.hansaYellow

    webView.translatesAutoresizingMaskIntoConstraints = false
    bottomView.translatesAutoresizingMaskIntoConstraints = false
    webViewVC.view.addSubview(closeButton)
    webViewVC.view.addSubview(webView)
    webViewVC.view.addSubview(versionLabel)
    webViewVC.view.addSubview(bottomView)

    NSLayoutConstraint.activate([
      webViewVC.view.topAnchor.constraint(equalTo: closeButton.topAnchor),
      webViewVC.view.leftAnchor.constraint(equalTo: closeButton.leftAnchor),
      webViewVC.view.rightAnchor.constraint(equalTo: closeButton.rightAnchor),
      webViewVC.view.leftAnchor.constraint(equalTo: webView.leftAnchor),
      webViewVC.view.rightAnchor.constraint(equalTo: webView.rightAnchor),
      webView.topAnchor.constraint(equalTo: closeButton.bottomAnchor),
      webView.bottomAnchor.constraint(equalTo: versionLabel.topAnchor),
      versionLabel.leftAnchor.constraint(equalTo: webViewVC.view.leftAnchor),
      versionLabel.rightAnchor.constraint(equalTo: webViewVC.view.rightAnchor),
      versionLabel.bottomAnchor.constraint(equalTo: webViewVC.view.layoutMarginsGuide.bottomAnchor),

      bottomView.topAnchor.constraint(equalTo: versionLabel.bottomAnchor),
      bottomView.leftAnchor.constraint(equalTo: webViewVC.view.leftAnchor),
      bottomView.rightAnchor.constraint(equalTo: webViewVC.view.rightAnchor),
      bottomView.bottomAnchor.constraint(equalTo: webViewVC.view.bottomAnchor)
    ])

    showLoadingIndicator()
    var langString = "en"
    if let languageCode = Locale.current.languageCode {
      if languageCode == "pt" {
        langString = "pt-BR"
      } else {
        langString = languageCode
      }

      let urlString = "https://htmlpreview.github.io/?https://github.com/misteu/VocabularyTraining/blob/master/VocabularyTrainer/\(langString).lproj/pp.html"

      if let ppUrl = URL(string: urlString) {
        webView.load(URLRequest(url: ppUrl))
      } else {
        loadLocalPp(webView)
      }
    } else {
      loadLocalPp(webView)
    }
  }

  // MARK: - Close
  @objc func tappedClose() {
    presentedViewController?.dismiss(animated: true)
  }

  // MARK: - New Language
  @objc func addAction() {
      coordinator?.navigateToNewLanguageViewController(newLanguageScreenProtocol: self)
  }
}

extension HomeScreenViewController: UITableViewDataSource, UITableViewDelegate {
  func tableView(_ tbleView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return checkNumberOfLanguages()
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

    if let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier.languageCell) as? LanguageTableViewCell {

      guard let language = defaults.array(forKey: UserDefaultKeys.languages)?[indexPath.item] as? String else { debugPrint("no language string"); return UITableViewCell() }

      cell.languageLabel.text = language

      if let vocabularies = UserDefaults.standard.dictionary(forKey: language) as? [String: String] {

        if (vocabularies.count != 1) {
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

  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    selectedRow = indexPath.item

    self.headerTextConstraintTop?.constant = 68.0
    UIView.animate(withDuration: 0.2, animations: {
      self.view.layoutIfNeeded()
      for button in self.topButtons {
        button.alpha = 1.0
        button.isHidden = false
      }
    })
  }
}

extension HomeScreenViewController: StoryBoarded {}
