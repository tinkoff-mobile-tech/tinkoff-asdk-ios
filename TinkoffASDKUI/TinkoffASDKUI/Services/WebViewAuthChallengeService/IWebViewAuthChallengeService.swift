//
//  IWebViewAuthChallengeService.swift
//  TinkoffASDKUI
//
//  Created by r.akhmadeev on 24.12.2022.
//

import Foundation
import WebKit

/// Запрашивает данные и способ аутентификация для `WKWebView`
public protocol IWebViewAuthChallengeService {
    /// Запрашивает данные и способ аутентификация для `WKWebView`
    func webView(
        _ webView: WKWebView,
        didReceive challenge: URLAuthenticationChallenge,
        completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void
    )
}
