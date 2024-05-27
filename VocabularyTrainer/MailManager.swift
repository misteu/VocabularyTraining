//
//  MailManager.swift
//  bread-timer
//
//  Created by skrr on 24.05.20.
//  Copyright © 2020 mic. All rights reserved.
//

import MessageUI
import SwiftUI

//struct MailManagerViewController: UIViewControllerRepresentable {
//
//}

final class MailManager: NSObject {
  static var shared = MailManager()
  func mailViewController() -> MFMailComposeViewController {
	if MFMailComposeViewController.canSendMail() {
	  let mail = MFMailComposeViewController()
	  mail.mailComposeDelegate = self
	  mail.setToRecipients(["contact@mic.st"])
	  mail.setSubject("Mail from Flippy")
	  mail.setMessageBody("<p>Hello Michael!</p><br>", isHTML: true)
	  return mail
	} else {
	  return MFMailComposeViewController(nibName: nil, bundle: nil)
	}
  }
}

extension MailManager: MFMailComposeViewControllerDelegate {
  func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
	controller.dismiss(animated: true)
  }
}

extension MailManager: UIViewControllerRepresentable {
  func updateUIViewController(_ uiViewController: MFMailComposeViewController, context: Context) {
	return
  }

  func makeUIViewController(context: Context) -> MFMailComposeViewController {
	return MailManager.shared.mailViewController()
  }
}
