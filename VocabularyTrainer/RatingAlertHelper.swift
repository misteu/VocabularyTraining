//
//  RatingAlertHelper.swift
//  GardenApp
//
//  Created by skrr on 02.12.22.
//  Copyright © 2022 mic. All rights reserved.
//

import UIKit
import StoreKit

struct RatingAlertHelper {

  static let shared = RatingAlertHelper()
  private static let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
  private let numberOfAppStarts = UserDefaults.standard.numberOfAppStarts


  /// Was the user asked for a review in this app version?
  private var askedForRatingOnThisVersion: Bool {
	if Self.appVersion != UserDefaults.standard.lastVersionAskedForReview {
	  print("didn't ask")
	  return false
	} else {
	  print("already asked")
	  return true
	}
  }

  func showPopupIfNeeded() {
	guard (
	  numberOfAppStarts + 1 == 3 ||
	  numberOfAppStarts + 1 == 5 ||
	  numberOfAppStarts + 1 == 8 ||
	  numberOfAppStarts + 1 == 12 ||
	  numberOfAppStarts + 1 == 15 ||
	  numberOfAppStarts + 1 == 18 ||
	  numberOfAppStarts + 1 == 21 ||
	  numberOfAppStarts + 1 == 24 ||
	  numberOfAppStarts + 1 == 27 ||
	  numberOfAppStarts + 1 == 30
	) && !askedForRatingOnThisVersion else { return }

   Self.askRatingAlert(isShowingPreAlert: false)

  }

  func incrementAppStart() {
	UserDefaults.standard.numberOfAppStarts += 1
	print("App started \(UserDefaults.standard.numberOfAppStarts) times")
  }
}

extension UserDefaults {

  private var numberOfAppStartsKey: String {
	"numberOfAppStartsKey"
  }

  private var lastVersionAskedKey: String {
	"lastVersionAskedKey"
  }

 @objc var numberOfAppStarts: Int {
	get {
	  integer(forKey: numberOfAppStartsKey)
	}
	set {
	  set(newValue, forKey: numberOfAppStartsKey)
	}
  }

  var lastVersionAskedForReview: String? {
	get {
	  string(forKey: lastVersionAskedKey)
	}
	set {
	  set(newValue, forKey: lastVersionAskedKey)
	}
  }
}

extension UIViewController {

	static func topmostViewController() -> UIViewController? {
		let keyWindow = UIApplication.shared.windows.filter {$0.isKeyWindow}.first
		if var topController = keyWindow?.rootViewController {
			while let presentedViewController = topController.presentedViewController {
				topController = presentedViewController
			}
			return topController
		}
		return nil
	}
}

extension UIApplication {
  var foregroundActiveScene: UIWindowScene? {
	connectedScenes
	  .first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene
  }
}


extension RatingAlertHelper {

	static func writeFeedbackMail() -> UIAlertController {
		let alert = UIAlertController(title: Strings.missingAnythingTitle,
									  message: Strings.missingAnythingText,
									  preferredStyle: .alert)
		alert.addAction(UIAlertAction(title: Strings.sendFeedbackMailButton,
									  style: .default,
									  handler: { _ in
			let mailController = MailManager.shared.mailViewController()
			UIViewController.topmostViewController()?.present(mailController, animated: true)
		}))
		alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: "Cancel button title"),
									  style: .cancel,
									  handler: { _ in }))
		return alert
	}

  /// Asks the user to give a rating.
	static func askRatingAlert(isShowingPreAlert: Bool) {
		if isShowingPreAlert {
			let alert = UIAlertController(title: Strings.doYouLikeTheAppTitle,
										  message: nil,
										  preferredStyle: .alert)
			alert.addAction(UIAlertAction(title: Strings.doYouLikeTheAppYesTitle,
										  style: .default,
										  handler: { _ in
				guard let scene = UIApplication.shared.foregroundActiveScene else { return }
				SKStoreReviewController.requestReview(in: scene)
				UserDefaults.standard.lastVersionAskedForReview = self.appVersion
			}))
			alert.addAction(UIAlertAction(title: Strings.doYouLikeTheAppNoTitle,
										  style: .cancel,
										  handler: { _ in
				UIViewController.topmostViewController()?.present(writeFeedbackMail(), animated: true)
			}))
//			return alert

			DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
				let keyWindow = UIApplication.shared.connectedScenes
						.filter({$0.activationState == .foregroundActive})
						.compactMap({$0 as? UIWindowScene})
						.first?.windows
						.filter({$0.isKeyWindow}).first

				keyWindow?.rootViewController?.present(alert, animated: true)
			}
		}
		else {
			DispatchQueue.main.asyncAfter(deadline: .now() + 4, execute: {
				guard let scene = UIApplication.shared.foregroundActiveScene else { return }
				SKStoreReviewController.requestReview(in: scene)
				UserDefaults.standard.lastVersionAskedForReview = self.appVersion
			})
		}
  }

  enum Strings {
	static let doYouLikeTheAppTitle = NSLocalizedString(
	  "rating_alert_likeTheApp_title",
	  tableName: "Localizable",
	  value: "Do you like the App?",
	  comment: "Title of the alert asking the user whether they like the app")
	static let doYouLikeTheAppYesTitle = NSLocalizedString(
	  "rating_alert_likeTheAppYesButton_title",
	  tableName: "Localizable",
	  value: "Yes",
	  comment: "Yes button title")
	static let doYouLikeTheAppNoTitle = NSLocalizedString(
	  "rating_alert_likeTheAppNoButton_title",
	  tableName: "Localizable",
	  value: "No",
	  comment: "No button title")

	  static let missingAnythingTitle = NSLocalizedString(
		"rating_alert_feedbackAlertTitle",
		tableName: "Localizable",
		value: "Give Feedback",
		comment: "Title of feedback alert appearing when user taps no")
	  static let missingAnythingText = NSLocalizedString(
		"rating_alert_feedbackAlertText",
		tableName: "Localizable",
		value: "Please do send an short feedback email to me for any requests, bug reports, etc.\n I highly do appreciate any feedback! ❤️\nTap the button below to open your mail app.",
		comment: "Title of feedback alert appearing when user taps no")
	  static let sendFeedbackMailButton = NSLocalizedString(
		"rating_alert_feedbackAlertMailButton",
		tableName: "Localizable",
		value: "Mail to contact@mic.st",
		comment: "Title of mail button")
  }
}
