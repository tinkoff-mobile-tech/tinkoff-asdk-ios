//
//  URLSessionDelegateImpl.swift
//  TinkoffASDKCore
//
//  Created by r.akhmadeev on 23.12.2022.
//

import Foundation

final class URLSessionDelegateImpl: NSObject, URLSessionDelegate {
    // MARK: Dependencies

    private let authChallengeService: IURLSessionAuthChallengeService

    // MARK: Init

    init(authChallengeService: IURLSessionAuthChallengeService) {
        self.authChallengeService = authChallengeService
    }

    // MARK: URLSessionDelegate

    func urlSession(
        _ session: URLSession,
        didReceive challenge: URLAuthenticationChallenge,
        completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void
    ) {
        authChallengeService.urlSession(
            session,
            didReceive: challenge,
            completionHandler: completionHandler
        )
    }
}
