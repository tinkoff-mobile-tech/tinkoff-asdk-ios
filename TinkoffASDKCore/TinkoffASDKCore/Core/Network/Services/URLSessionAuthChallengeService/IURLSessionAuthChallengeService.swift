//
//  IURLSessionAuthChallengeService.swift
//  TinkoffASDKCore
//
//  Created by r.akhmadeev on 23.12.2022.
//

import Foundation

/// Запрашивает данные и способ аутентификация для `URLSession`
public protocol IURLSessionAuthChallengeService {
    /// Запрашивает данные и способ аутентификация для `URLSession`
    func urlSession(
        _ session: URLSession,
        didReceive challenge: URLAuthenticationChallenge,
        completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void
    )
}
