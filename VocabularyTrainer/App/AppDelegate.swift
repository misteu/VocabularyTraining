//
//  AppDelegate.swift
//  VocabularyTrainer
//
//  Created by skrr on 10.03.19.
//  Copyright © 2019 mic. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

  var window: UIWindow?
  var coordinator: MainCoordinator?
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
//    activate later!
//    if let files = ExportImport.getAllLanguageFileUrls() {
//      ExportImport.importLanguageFiles(files)
//    }
      window = .init()
      let navigationController = UINavigationController()
      navigationController.navigationBar.tintColor = .black
      coordinator = MainCoordinator(navigationController: navigationController)
      coordinator?.start()
      window?.rootViewController = navigationController
      window?.makeKeyAndVisible()

	  RatingAlertHelper.shared.incrementAppStart()
	  RatingAlertHelper.shared.showPopupIfNeeded()

    return true
  }

  func applicationWillResignActive(_ application: UIApplication) {
    // Sent when the application is about to move from active to inactive state.
    // This can occur for certain types of temporary interruptions (such as an
    // incoming phone call or SMS message) or when the user quits the application
    // and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics
    // rendering callbacks. Games should use this method to pause the game.
  }

  func applicationDidEnterBackground(_ application: UIApplication) {
    // saveLanguages()
  }
    
  func applicationWillEnterForeground(_ application: UIApplication) {
      // Called as part of the transition from the background to the active state;
      // here you can undo many of the changes made on entering the background.
  }

  func applicationDidBecomeActive(_ application: UIApplication) {
    // Restart any tasks that were paused (or not yet started) while the application was
    // inactive. If the application was previously in the background, optionally refresh
    // the user interface.
  }

  func applicationWillTerminate(_ application: UIApplication) {
    // saveLanguages()
  }

  func saveLanguages() {
    guard let languages = UserDefaults.standard.array(forKey: UserDefaultKeys.languages) as? [String] else { return }

    for language in languages {
      ExportImport.exportAsCsvToDocuments(language: language)
    }
  }
}
