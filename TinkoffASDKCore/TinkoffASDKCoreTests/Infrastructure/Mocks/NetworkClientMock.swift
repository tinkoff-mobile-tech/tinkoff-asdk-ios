//
//  NetworkClientMock.swift
//  TinkoffASDKCore-Unit-Tests
//
//  Created by r.akhmadeev on 24.10.2022.
//

import Foundation
@testable import TinkoffASDKCore

final class NetworkClientMock: INetworkClient {
    var invokedPerformRequest = false
    var invokedPerformRequestCount = 0
    var invokedPerformRequestParameters: (request: NetworkRequest, Void)?
    var invokedPerformRequestParametersList = [(request: NetworkRequest, Void)]()
    var stubbedPerformRequestCompletionResult: (Result<NetworkResponse, NetworkError>, Void)?
    var stubbedPerformRequestResult: Cancellable!

    func performRequest(
        _ request: NetworkRequest,
        completion: @escaping (Result<NetworkResponse, NetworkError>) -> Void
    ) -> Cancellable {
        invokedPerformRequest = true
        invokedPerformRequestCount += 1
        invokedPerformRequestParameters = (request, ())
        invokedPerformRequestParametersList.append((request, ()))
        if let result = stubbedPerformRequestCompletionResult {
            completion(result.0)
        }
        return stubbedPerformRequestResult
    }
}
