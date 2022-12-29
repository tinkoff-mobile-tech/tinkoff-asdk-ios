//
//  TokenProviderMock.swift
//  TinkoffASDKCore-Unit-Tests
//
//  Created by r.akhmadeev on 25.10.2022.
//

import Foundation
import TinkoffASDKCore

final class TokenProviderMock: ITokenProvider {
    typealias ProvideTokenCompletion = (Result<String, Error>) -> Void

    var invokedProvideToken = false
    var invokedProvideTokenCount = 0
    var invokedProvideTokenParameters: [String: String]?
    var invokedProvideTokenParametersList = [[String: String]]()

    var provideTokenMethodStub = { (parameters: [String: String], completion: @escaping ProvideTokenCompletion) in
        completion(.success("testToken"))
    }

    func provideToken(
        forRequestParameters parameters: [String: String],
        completion: @escaping (Result<String, Error>) -> Void
    ) {
        invokedProvideToken = true
        invokedProvideTokenCount += 1
        invokedProvideTokenParameters = parameters
        invokedProvideTokenParametersList.append(parameters)
        provideTokenMethodStub(parameters, completion)
    }
}
