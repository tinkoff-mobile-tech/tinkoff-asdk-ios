//
//
//  ThreeDSWebViewController.swift
//
//  Copyright (c) 2021 Tinkoff Bank
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//   http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import TinkoffASDKCore
import UIKit
import WebKit

final class ThreeDSWebViewController<Payload: Decodable>: UIViewController, WKNavigationDelegate {
    // MARK: Dependencies

    private let urlRequest: URLRequest
    private let handler: IThreeDSWebViewHandler
    private let authChallengeService: IWebViewAuthChallengeService
    private var completion: ((ThreeDSWebViewHandlingResult<Payload>) -> Void)?

    // MARK: Subviews

    private lazy var webView = WKWebView()
    private let hidingView = UIView()

    // MARK: Init

    init(
        urlRequest: URLRequest,
        handler: IThreeDSWebViewHandler,
        authChallengeService: IWebViewAuthChallengeService,
        completion: @escaping (ThreeDSWebViewHandlingResult<Payload>) -> Void
    ) {
        self.urlRequest = urlRequest
        self.handler = handler
        self.authChallengeService = authChallengeService
        self.completion = completion
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Life Cycle

    override func loadView() {
        view = webView
        webView.navigationDelegate = self
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupCloseButton()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        webView.load(urlRequest)
        hidingView.frame = webView.frame
        hidingView.backgroundColor = ASDKColors.Background.base.color
        hidingView.isHidden = true
    }

    // MARK: WKNavigationDelegate

    func webView(
        _ webView: WKWebView,
        didReceive challenge: URLAuthenticationChallenge,
        completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void
    ) {
        authChallengeService.webView(
            webView,
            didReceive: challenge,
            completionHandler: completionHandler
        )
    }

    func webView(
        _ webView: WKWebView,
        decidePolicyFor navigationResponse: WKNavigationResponse,
        decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void
    ) {
        let isShowingJsonMimeType = navigationResponse.response.mimeType == .jsonMimeType
        hidingView.isHidden = !isShowingJsonMimeType
        hidingView.removeFromSuperview()
        if isShowingJsonMimeType {
            webView.addSubview(hidingView)
        }
        decisionHandler(.allow)
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        webView.evaluateJavaScript(.baseURI) { [weak self] value, error in
            guard error == nil, let uri = value as? String else {
                return
            }

            webView.evaluateJavaScript(.jsonText) { value, _ in
                guard let response = value as? String,
                      let responseData = response.data(using: .utf8),
                      let self = self
                else { return }

                let handlingResult: ThreeDSWebViewHandlingResult<Payload>? = self.handler.handle(
                    urlString: uri,
                    responseData: responseData
                )

                if let handlingResult = handlingResult {
                    self.callbackResult(handlingResult)
                }
            }
        }
    }

    // MARK: Helpers

    private func setupCloseButton() {
        let cancelButton: UIBarButtonItem
        if #available(iOS 13.0, *) {
            cancelButton = UIBarButtonItem(
                barButtonSystemItem: .close,
                target: self,
                action: #selector(closeButtonTapped)
            )
        } else {
            cancelButton = UIBarButtonItem(
                title: Loc.TinkoffAcquiring.Button.close,
                style: .done,
                target: self,
                action: #selector(closeButtonTapped)
            )
        }
        navigationItem.setRightBarButton(cancelButton, animated: true)
    }

    @objc private func closeButtonTapped() {
        callbackResult(.cancelled)
    }

    private func callbackResult(_ result: ThreeDSWebViewHandlingResult<Payload>) {
        guard let completion = completion else { return }
        self.completion = nil

        dismiss(animated: true) {
            completion(result)
        }
    }
}

private extension String {
    // Javascript code snippets
    static let baseURI = "document.baseURI"
    static let jsonText = "document.getElementsByTagName('pre')[0].innerText"
    static let jsonMimeType = "application/json"
}
