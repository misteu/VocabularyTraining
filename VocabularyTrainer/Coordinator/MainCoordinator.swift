//
//  MainCoordinator.swift
//  VocabularyTrainer
//
//  Created by Pranjal Verma on 30/10/22.
//  Copyright © 2022 mic. All rights reserved.
//

import Foundation
import UIKit

class MainCoordinator: Coordinator {
    var childCoordinator = [Coordinator]()
    
    var navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        guard let vc = HomeScreenViewController.instantiate() else { print("[ERROR] Unable to instantiate TrainingViewController"); return }
        vc.coordinator = self
        navigationController.pushViewController(vc, animated: false)
    }

    func navigateToNewLanguageViewController(newLanguageScreenProtocol: NewLanguageScreenProtocol) {
        let newLanguageVC = NewLanguageViewController(delegate: newLanguageScreenProtocol)
        newLanguageVC.coordinator = self
        
        navigationController.pushViewController(newLanguageVC, animated: true)
    }
    
    func navigateToLanguageScreenViewController(selectedLanguage: String?, newLanguageScreenProtocol: NewLanguageScreenProtocol, completion: @escaping(() -> Void)) {
        let languageScreenVC = LanguageScreenViewController()
        languageScreenVC.selectedLanguage = selectedLanguage
        languageScreenVC.delegate = newLanguageScreenProtocol
        languageScreenVC.completed = {
            completion()
        }
        languageScreenVC.coordinator = self
        navigationController.pushViewController(languageScreenVC, animated: true)
    }
    
    func navigateToAddNewWordViewController(selectedLanguage: String?, delegate: AddWordDelegate?) {
        let addNewWordVC = AddNewWordViewController(selectedLanguage: selectedLanguage)
        addNewWordVC.coordinator = self
        addNewWordVC.delegate = delegate
        navigationController.pushViewController(addNewWordVC, animated: true)
    }
    
  func navigateToTrainingViewController(with language: String) {
    let trainingVC = TrainingViewController(with: language)
    trainingVC.coordinator = self
    navigationController.pushViewController(trainingVC, animated: true)
  }

    func popVC() {
        navigationController.popViewController(animated: true)
    }
    
}
