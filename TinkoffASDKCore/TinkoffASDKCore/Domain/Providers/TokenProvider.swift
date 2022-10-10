//
//  TokenProvider.swift
//  TinkoffASDKCore
//
//  Created by r.akhmadeev on 10.10.2022.
//

import Foundation

public protocol ITokenProvider {
    func provideToken(
        forRequestParameters parameters: [String: Any],
        completion: @escaping (Result<String, Error>) -> Void
    )
}
