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

    // MARK: - webView

    typealias WebViewArguments = (webView: WKWebView, challenge: URLAuthenticationChallenge, completionHandler: (URLSession.AuthChallengeDisposition, URLCredential?) -> Void)

    var webViewCallsCount = 0
    var webViewReceivedArguments: WebViewArguments?
    var webViewReceivedInvocations: [WebViewArguments?] = []
    var webViewCompletionHandlerClosureInput: (URLSession.AuthChallengeDisposition, URLCredential?)?

    func webView(_ webView: WKWebView, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        webViewCallsCount += 1
        let arguments = (webView, challenge, completionHandler)
        webViewReceivedArguments = arguments
        webViewReceivedInvocations.append(arguments)
        if let webViewCompletionHandlerClosureInput = webViewCompletionHandlerClosureInput {
            completionHandler(
                webViewCompletionHandlerClosureInput.0,
                webViewCompletionHandlerClosureInput.1
            )
        }
    }
}

// MARK: - Resets

extension WebViewAuthChallengeServiceMock {
    func fullReset() {
        webViewCallsCount = 0
        webViewReceivedArguments = nil
        webViewReceivedInvocations = []
        webViewCompletionHandlerClosureInput = nil
    }
}
