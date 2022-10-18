//
//
//  ThreeDSViewController.swift
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

final class ThreeDSViewController<Payload: Decodable>: UIViewController, WKNavigationDelegate {
    private let urlRequest: URLRequest
    private let handler: IThreeDSWebViewHandler

    lazy var webView = WKWebView()

    private var didHandle: ((Result<Payload, Error>) -> Void)?

    init(
        urlRequest: URLRequest,
        handler: IThreeDSWebViewHandler,
        didHandle: ((Result<Payload, Error>) -> Void)?
    ) {
        self.urlRequest = urlRequest
        self.handler = handler
        self.didHandle = didHandle
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

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
    }

    // MARK: - WKNavigationDelegate

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        webView.evaluateJavaScript("document.baseURI") { value, error in
            guard error == nil, let uri = value as? String else {
                return
            }

            webView.evaluateJavaScript("document.getElementsByTagName('pre')[0].innerText") { [weak self] value, _ in
                guard let self = self, let response = value as? String, let responseData = response.data(using: .utf8) else {
                    return
                }

                let result: Result<Payload, Error> = self.handler.handle(urlString: uri, responseData: responseData)

                self.didHandle?(result)
            }
        }
    }

    private func setupCloseButton() {
        let cancelButton: UIBarButtonItem
        if #available(iOS 13.0, *) {
            cancelButton = UIBarButtonItem(
                barButtonSystemItem: .close,
                target: self,
                action: #selector(didTapCloseButton)
            )
        } else {
            cancelButton = UIBarButtonItem(
                title: Loc.TinkoffAcquiring.Button.close,
                style: .done,
                target: self,
                action: #selector(didTapCloseButton)
            )
        }
        navigationItem.setRightBarButton(cancelButton, animated: true)
    }

    @objc func didTapCloseButton() {
        handler.didCancel?()
    }
}
