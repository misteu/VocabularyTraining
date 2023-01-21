//
//  AboutViewController.swift
//  VocabularyTrainer
//
//  Created by skrr on 04.01.23.
//  Copyright © 2023 mic. All rights reserved.
//

import UIKit
import WebKit

/// Shows privacy policy loaded from an HTML located in the Github repo.
final class AboutViewController: UIViewController {
    /// The webview showing the html.
    private let webView = WKWebView(frame: .zero)
    /// The loading alert.
    private var loadingAlert: UIAlertController = {
        let alertController = UIAlertController(title: nil,
                                                message: Strings.pleaseWaitTitle,
                                                preferredStyle: .alert)
        alertController.view.tintColor = .black
        let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.style = .medium
        loadingIndicator.startAnimating()
        alertController.view.addSubview(loadingIndicator)
        return alertController
    }()
    /// The string added to the html's url to get the correct PP for the user's locale.
    private var langCodeString: String {
        var langString = "en"
        if let languageCode = Locale.current.languageCode {
            if languageCode == "pt" {
                langString = "pt-BR"
            } else {
                langString = languageCode
            }
        }
        return langString
    }
    /// The PP's location.
    private var urlString: String {
        "https://htmlpreview.github.io/?https://github.com/misteu/VocabularyTraining/blob/master/VocabularyTrainer/\(langCodeString).lproj/pp.html"
    }

    /// Close button for the navbar, shown when initial url (`urlString`) is loaded.
    private lazy var closeButton: UIBarButtonItem = {
        let button = UIBarButtonItem(title: Strings.backButtonTitle,
                                     image: UIImage(systemName: "x.circle"),
                                     primaryAction: .init(handler: { [weak self] _ in
            self?.dismiss(animated: true)
        }), menu: nil)
        button.tintColor = HomeViewModel.Colors.flippyGreen
        return button
    }()

    /// Back button for the navbar, shown when navigated away from `urlString`.
    private lazy var backButton: UIBarButtonItem = {
        let button = UIBarButtonItem(title: Strings.backButtonTitle,
                                     image: UIImage(systemName: "chevron.left"),
                                     primaryAction: .init(handler: { [weak self] _ in
            self?.webView.goBack()
            }), menu: nil)
        button.tintColor = HomeViewModel.Colors.flippyGreen
        return button
    }()

    /// Label showing the version number of the app.
    private let versionLabel: UILabel = {
        let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
        let text = "FlippyLearn Version: \(appVersion ?? "unknown")"
        let label = UILabel.createLabel(text: text, fontColor: UIColor.black, textAlignment: .center)
        label.backgroundColor = HomeViewModel.Colors.flippyGreen
        return label
    }()

    /// View below label making it nicer for devices without home button.
    private let bottomView: UIView = {
        let view = UIView()
        view.backgroundColor = HomeViewModel.Colors.flippyGreen
        return view
    }()

    // MARK: - Init

    init() {
        super.init(nibName: nil, bundle: nil)
        webView.navigationDelegate = self
        setupUI()
        setupConstraints()
    }

    required init?(coder: NSCoder) { nil }

    // MARK: - View Lifecycle

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navigateToPP()
    }

    // MARK: - Private Methods

    private func setupUI() {
        title = Strings.title
        view.backgroundColor = .systemBackground
        navigationItem.leftBarButtonItem = closeButton
        view.addSubviews([webView, versionLabel, bottomView])
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            webView.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            webView.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor),
            webView.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
            webView.bottomAnchor.constraint(equalTo: versionLabel.topAnchor),

            versionLabel.leftAnchor.constraint(equalTo: view.leftAnchor),
            versionLabel.rightAnchor.constraint(equalTo: view.rightAnchor),
            versionLabel.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor),

            bottomView.topAnchor.constraint(equalTo: versionLabel.bottomAnchor),
            bottomView.leftAnchor.constraint(equalTo: view.leftAnchor),
            bottomView.rightAnchor.constraint(equalTo: view.rightAnchor),
            bottomView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    /// Navigates to initial initial website (`urlString`).
    private func navigateToPP() {
        if let ppUrl = URL(string: urlString) {
            webView.load(URLRequest(url: ppUrl))
        } else {
            loadLocalPp()
        }
    }

    /// Loads fallback local html.
    private func loadLocalPp() {
        guard let htmlFile = Bundle.main.path(forResource: "pp", ofType: "html") else { return }
        guard let html = try? String(contentsOfFile: htmlFile, encoding: String.Encoding.utf8) else { return }
        webView.loadHTMLString(html, baseURL: nil)
    }

    /// Shows loading alert.
    private func showLoadingIndicator() {
        present(loadingAlert, animated: true, completion: nil)
    }
}

// MARK: - WKNavigationDelegate

extension AboutViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        if presentedViewController === loadingAlert {
            dismiss(animated: true)
        }
        navigationItem.leftBarButtonItem = webView.url?.absoluteString == urlString ? closeButton : backButton
    }

    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        showLoadingIndicator()
    }
}

// MARK: - Strings

extension AboutViewController {
    enum Strings {
        static let pleaseWaitTitle = NSLocalizedString(
            "Please wait...",
            comment: "Message on loading indicator"
        )
        static let title = NSLocalizedString(
            "About Flippy App",
            comment: "Title of about screen"
        )
        static let backButtonTitle = NSLocalizedString(
            "Back",
            comment: "Title of back button"
        )
        static let closeButtonTitle = NSLocalizedString(
            "Close",
            comment: "Title of close button"
        )
    }
}
