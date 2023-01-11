//
//  WebViewAuthChallengeServiceMock.swift
//  TinkoffASDKUI-Unit-Tests
//
//  Created by r.akhmadeev on 28.12.2022.
//

import Foundation
@testable import TinkoffASDKUI
import WebKit

final class WebViewAuthChallengeServiceMock: IWebViewAuthChallengeService {
    var invokedWebView = false
    var invokedWebViewCount = 0
    var invokedWebViewParameters: (webView: WKWebView, challenge: URLAuthenticationChallenge)?
    var invokedWebViewParametersList = [(webView: WKWebView, challenge: URLAuthenticationChallenge)]()
    var stubbedWebViewCompletionHandlerResult: (URLSession.AuthChallengeDisposition, URLCredential?)?

    func webView(
        _ webView: WKWebView,
        didReceive challenge: URLAuthenticationChallenge,
        completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void
    ) {
        invokedWebView = true
        invokedWebViewCount += 1
        invokedWebViewParameters = (webView, challenge)
        invokedWebViewParametersList.append((webView, challenge))
        if let result = stubbedWebViewCompletionHandlerResult {
            completionHandler(result.0, result.1)
        }
    }
}
