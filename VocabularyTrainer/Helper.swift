//
//  Helper.swift
//  VocabularyTrainer
//
//  Created by skrr on 10.03.19.
//  Copyright © 2019 mic. All rights reserved.
//

import Foundation
import UIKit

enum CellIdentifier {
  static let vocabularyCell = "vocabularyCell"
}

enum Layout {
    /// default button height of 44.
    static let defaultButtonHeight: CGFloat = 44
    /// default margin of 16.
    static let defaultMargin: CGFloat = 16
}

struct BackgroundColor {
  static let blue = UIColor.init(red: 36/255, green: 110/255, blue: 185/255, alpha: 0.5)
  static let fullBlue = UIColor.init(red: 36/255, green: 110/255, blue: 185/255, alpha: 1.0)
  static let lightBlue = UIColor.init(red: 36/255, green: 110/255, blue: 185/255, alpha: 0.2)
  static let green = UIColor.init(red: 72/255, green: 175/255, blue: 64/255, alpha: 0.8)
  static let lightGreen = UIColor.init(red: 72/255, green: 175/255, blue: 64/255, alpha: 0.2)
  static let red = UIColor.init(red: 240/255, green: 101/255, blue: 67/255, alpha: 0.8)
  static let yellow = UIColor.init(red: 219/255, green: 213/255, blue: 110/255, alpha: 0.8)
  static let lightyellow = UIColor.init(red: 219/255, green: 213/255, blue: 110/255, alpha: 0.4)
  
  // rgb(211, 157, 56)
  static let gradientYellow = UIColor(red: 211/255, green: 157/255, blue: 56/255, alpha: 0.8)
  
  // rgb(242, 220, 93)
  static let gradientYellowBrighter = UIColor(red: 242/255, green: 220/255, blue: 93/255, alpha: 1.0)
  
  // rgb(77, 160, 176)
  static let gradientBlue = UIColor(red: 77/255, green: 160/255, blue: 176/255, alpha: 0.8)
  
  // rgb(38, 70, 83)
  static let japaneseIndigo = UIColor(red: 38/255, green: 70/255, blue: 83/255, alpha: 1.0)
  
//  rgb(233, 196, 106) //TopButton color
  static let hansaYellow = UIColor(red: 233/255, green: 196/255, blue: 106/255, alpha: 1.0)
  
//  rgb(214, 230, 129)
  static let mediumSpringBud = UIColor(red: 214/255, green: 230/255, blue: 129/255, alpha: 1.0)
  
  // rgb(67, 233, 123)
  static let africanViolet = UIColor(red: 94/255, green: 231/255, blue: 223/255, alpha: 1.0)
  
  // rgb(56, 249, 215)
  static let turquoise = UIColor(red: 180/255, green: 144/255, blue: 202/255, alpha: 1.0)
  
  static let mediumWhite = UIColor(white: 1.0, alpha: 0.8)
}

func setGradientBackground(view: UIView) {
  if let colorTop = UIColor(named: "backgroundGradientTop")?.cgColor,
     let colorBottom = UIColor(named: "backgroundGradientBottom")?.cgColor {

    let gradientLayer = CAGradientLayer()
    gradientLayer.colors = [colorTop, colorBottom]
    gradientLayer.locations = [0.0, 1.0]
    gradientLayer.frame = view.bounds

    view.layer.insertSublayer(gradientLayer, at: 0)
  }
}

func setGradientBackgroundTraining(view: UIView) {
  let colorTop = BackgroundColor.africanViolet.cgColor
  let colorBottom =  BackgroundColor.turquoise.cgColor
  let gradientLayer = CAGradientLayer()
  
  gradientLayer.colors = [colorTop, colorBottom]
  gradientLayer.locations = [0.0, 1.0]
  gradientLayer.frame = view.bounds
  
  view.layer.insertSublayer(gradientLayer, at: 0)
}

func loadVocabs(forLanguage language: String) -> [(String, String, Float)]? {
  
  guard let vocab = UserDefaults.standard.dictionary(forKey: language) as? [String: String] else { return nil }
  
  guard let vocabProgress = UserDefaults.standard.dictionary(forKey: "\(language)Progress") as? [String: Float] else { print("no progresses found"); return nil }

  var vocabularies = [(String, String, Float)]()
  for (key, value) in vocab {
    vocabularies.append((key, value, vocabProgress[key] ?? 100.0))
  }
  return vocabularies
}

class ExportImport {
  
  @discardableResult static func exportAsCsvToDocuments(language: String) -> String {
    var vocabDict: [String: String]
    var vocabProgr: [String: Float]
    var vocabularies = [(String, String, Float)]()
	var datesAdded = [String: Date]()

    if let vocab = UserDefaults.standard.dictionary(forKey: language) as? [String: String] {
      vocabDict = vocab
    } else {
      vocabDict = [String: String]()
    }
    
    guard let vocabProgress = UserDefaults.standard.dictionary(forKey: "\(language)Progress") as? [String: Float] else { print("no progresses found"); return ""}

	if let dates = UserDefaults.standard.dictionary(forKey: "\(language)DateAdded") as? [String: Date] {
		datesAdded = dates
	}

    vocabProgr = vocabProgress
    
    for (key, value) in vocabDict {
      vocabularies.append((key, value, vocabProgress[key] ?? 100.0))
    }
    
    let exportStringHead = """
    \(language)
    word;translation;progress;dateAdded
    """
    var exportString = ""
    
    for (key, value) in vocabDict {
      
      if !exportString.isEmpty {
        exportString = """
        \(exportString)
        \(key);\(value);\(vocabProgr[key] ?? 100);\(VocabularyDateFormatter.dateFormatter.string(from: datesAdded[key] ?? Date()))
        """
      } else {
        exportString = "\(key);\(value);\(vocabProgr[key] ?? 100)"
      }
    }
    
    exportString = """
    \(exportStringHead)
    \(exportString)
    """

    return exportString
    
//    let file = "\(language).csv"
//    if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
//
//      let fileURL = dir.appendingPathComponent(file)
//
//      //writing
//      do {
//        try exportString.write(to: fileURL, atomically: false, encoding: .macOSRoman)
//
//      }
//      catch { let error = error
//        print(error)
//      }
    
//    }
    
  }
  
  static func getAllLanguageFileUrls() -> [URL]? {
    if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
      
      do {
        let directoryContents = try FileManager.default.contentsOfDirectory(at: dir, includingPropertiesForKeys: nil, options: [])
        return directoryContents
      } catch {
        return nil
      }
    }
    return nil
  }
  
	static func importLanguageFiles(_ files: [URL], presentingViewController: HomeViewController) {
    for file in files {
      debugPrint(file.lastPathComponent)
//      let rawCsvImport = importLanguageFile(language: file.lastPathComponent)
		var rawStringImport = ""
		do {
		  rawStringImport = try String(contentsOf: file, encoding: .utf8)
		} catch { let error = error
		  print(error)
		}
      let importedCsvAsDicts = csv(data: rawStringImport)
      updateUserDefFromImports(imports: importedCsvAsDicts, language: file.deletingPathExtension().lastPathComponent, presentingViewController: presentingViewController)
    }
  }
  
  static func importLanguageFile(language: String) -> String {
    let file = language
    var result = ""
    
    if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
      let fileURL = dir.appendingPathComponent(file)
      
      do {
        result = try String(contentsOf: fileURL, encoding: .utf8)
      } catch { let error = error
        print(error)
      }
      
    }
    return result
  }
  
	static func updateUserDefFromImports(imports: LanguageImport, language: String, presentingViewController: HomeViewController) {
     let languageVocabProgressKey = "\(language)Progress"

     if var savedLanguages = UserDefaults.standard.array(forKey: UserDefaultKeys.languages) as? [String] {
       
       // Append language if not found
       if !savedLanguages.contains(language) {
         savedLanguages.append(language)
		   UserDefaults.standard.set(savedLanguages, forKey: UserDefaultKeys.languages)
		   UserDefaults.standard.set(imports.vocabularies, forKey: language)
		   UserDefaults.standard.set(imports.progresses, forKey: languageVocabProgressKey)
		   presentingViewController.applyCollectionViewChanges()
       } else {
		   let message = String(format: NSLocalizedString("alert_import_language_existing_message", comment: "Warning message when importing an already existing language"), language)
		   let title = NSLocalizedString("alert_import_language_existing_title", comment: "Title for already existing language warning")
		   let alert = UIAlertController(
			title: title,
			message: message,
			preferredStyle: .alert)
		   
		   // add the actions (buttons)
		   alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: "Cancel button title"), style: UIAlertAction.Style.cancel, handler: nil))
		   alert.addAction(UIAlertAction(title: NSLocalizedString("home_import_button_title", comment: "Import button title"), style: UIAlertAction.Style.default, handler: { _ in
			   UserDefaults.standard.set(savedLanguages, forKey: UserDefaultKeys.languages)
			   UserDefaults.standard.set(imports.vocabularies, forKey: language)
			   UserDefaults.standard.set(imports.progresses, forKey: languageVocabProgressKey)
			   presentingViewController.applyCollectionViewChanges()
		   }))
		   presentingViewController.present(alert, animated: true)
	   }
     } else {
       UserDefaults.standard.set([language], forKey: UserDefaultKeys.languages)
     }
   }
  
  static func csv(data: String) -> LanguageImport {
    var vocabDict = [String: String]()
    var vocabProgr = [String: Float]()
	var datesAdded = [String: Date]()
    
    let rows = data.components(separatedBy: "\n")
    for (index, row) in rows.enumerated() where index > 1 {
        let columns = row.components(separatedBy: ";")
        vocabDict[columns[0]] = columns[1]
        vocabProgr[columns[0]] = (columns[2] as NSString).floatValue
		var date: Date? = Date()
		if columns.indices.contains(3) {
			date = VocabularyDateFormatter.dateFormatter.date(from: columns[3])
		}
        datesAdded[columns[0]] = date
    }
  
	let result = LanguageImport.init(vocabularies: vocabDict, progresses: vocabProgr, datesAdded: datesAdded)
  
    return result
  }
}
