//
//  TokenProviderMock.swift
//  TinkoffASDKCore-Unit-Tests
//
//  Created by r.akhmadeev on 25.10.2022.
//

import Foundation
import TinkoffASDKCore

final class TokenProviderMock: ITokenProvider {

    // MARK: - provideToken

    typealias ProvideTokenArguments = (parameters: [String: String], completion: (Result<String, Error>) -> Void)

    var provideTokenCallsCount = 0
    var provideTokenReceivedArguments: ProvideTokenArguments?
    var provideTokenReceivedInvocations: [ProvideTokenArguments?] = []
    var provideTokenCompletionClosureInput: Result<String, Error>? = .success("testToken")

    func provideToken(forRequestParameters parameters: [String: String], completion: @escaping (Result<String, Error>) -> Void) {
        provideTokenCallsCount += 1
        let arguments = (parameters, completion)
        provideTokenReceivedArguments = arguments
        provideTokenReceivedInvocations.append(arguments)
        if let provideTokenCompletionClosureInput = provideTokenCompletionClosureInput {
            completion(provideTokenCompletionClosureInput)
        }
    }
}

// MARK: - Resets

extension TokenProviderMock {
    func fullReset() {
        provideTokenCallsCount = 0
        provideTokenReceivedArguments = nil
        provideTokenReceivedInvocations = []
        provideTokenCompletionClosureInput = nil
    }
}
