//
//  UISDKConfiguration.swift
//  TinkoffASDKUI
//
//  Created by r.akhmadeev on 24.12.2022.
//

import Foundation

/// Конфигурация `TinkoffASDKUI`
public struct UISDKConfiguration {
    /// Запрашивает данные и способ аутентификация для `WKWebView`
    let webViewAuthChallengeService: IWebViewAuthChallengeService?

    /// Инициалищация конфигурации `TinkoffASDKUI`
    /// - Parameter webViewAuthChallengeService: Запрашивает данные и способ аутентификация для `WKWebView`
    public init(webViewAuthChallengeService: IWebViewAuthChallengeService? = nil) {
        self.webViewAuthChallengeService = webViewAuthChallengeService
    }
}
