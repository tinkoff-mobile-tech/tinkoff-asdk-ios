//
//  DefaultURLSessionAuthChallengeService.swift
//  TinkoffASDKCore
//
//  Created by r.akhmadeev on 23.12.2022.
//

import Foundation

final class DefaultURLSessionAuthChallengeService: IURLSessionAuthChallengeService {
    func urlSession(
        _ session: URLSession,
        didReceive challenge: URLAuthenticationChallenge,
        completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void
    ) {
        completionHandler(.performDefaultHandling, nil)
    }
}
