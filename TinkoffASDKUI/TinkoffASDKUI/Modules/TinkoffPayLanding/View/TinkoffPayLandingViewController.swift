//
//  TinkoffPayLandingViewController.swift
//  TinkoffASDKUI
//
//  Created by r.akhmadeev on 12.03.2023.
//

import Foundation
import UIKit
import WebKit

final class TinkoffPayLandingViewController: UIViewController {
    // MARK: Dependencies

    private let authChallengeService: IWebViewAuthChallengeService

    // MARK: Subviews

    private lazy var webView = WKWebView()

    // MARK: Init

    init(authChallengeService: IWebViewAuthChallengeService) {
        self.authChallengeService = authChallengeService
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupWebView()
        setupNavigationItem()
        loadTinkoffPayLanding()
    }

    // MARK: Helpers

    private func setupWebView() {
        view.addSubview(webView)
        webView.pinEdgesToSuperview()
        webView.navigationDelegate = self
    }

    private func setupNavigationItem() {
        let closeButton: UIBarButtonItem

        if #available(iOS 13.0, *) {
            closeButton = UIBarButtonItem(
                barButtonSystemItem: .close,
                target: self,
                action: #selector(closeButtonTapped)
            )
        } else {
            closeButton = UIBarButtonItem(
                title: Loc.TinkoffAcquiring.Button.close,
                style: .done,
                target: self,
                action: #selector(closeButtonTapped)
            )
        }

        navigationItem.rightBarButtonItem = closeButton
    }

    private func loadTinkoffPayLanding() {
        webView.load(URLRequest(url: .landingURL))
    }

    // MARK: Events

    @objc private func closeButtonTapped() {
        dismiss(animated: true)
    }
}

// MARK: - WKNavigationDelegate

extension TinkoffPayLandingViewController: WKNavigationDelegate {
    func webView(
        _ webView: WKWebView,
        didReceive challenge: URLAuthenticationChallenge,
        completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void
    ) {
        authChallengeService.webView(webView, didReceive: challenge, completionHandler: completionHandler)
    }
}

// MARK: - Constants

private extension URL {
    static let landingURL = URL(string: "https://www.tinkoff.ru/cards/debit-cards/tinkoff-pay/form/")!
}
