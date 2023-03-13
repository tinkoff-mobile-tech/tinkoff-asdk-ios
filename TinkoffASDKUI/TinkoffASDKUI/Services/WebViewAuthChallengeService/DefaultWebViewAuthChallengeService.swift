//
//  DefaultWebViewAuthChallengeService.swift
//  TinkoffASDKUI
//
//  Created by r.akhmadeev on 24.12.2022.
//

import Foundation
import TinkoffASDKCore
import WebKit

final class DefaultWebViewAuthChallengeService: DefaultAuthChallengeService, IWebViewAuthChallengeService {
    func webView(
        _ webView: WKWebView,
        didReceive challenge: URLAuthenticationChallenge,
        completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void
    ) {
        super.didReceive(challenge: challenge, completionHandler: completionHandler)
    }
}
