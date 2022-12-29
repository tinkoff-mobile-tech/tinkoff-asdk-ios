//
//  NetworkClientMock.swift
//  TinkoffASDKCore-Unit-Tests
//
//  Created by r.akhmadeev on 24.10.2022.
//

import Foundation
@testable import TinkoffASDKCore

final class NetworkClientMock: INetworkClient {
    typealias PerformRequestCompletion = (Result<NetworkResponse, NetworkError>) -> Void

    var invokedPerformRequest = false
    var invokedPerformRequestCount = 0
    var invokedPerformRequestParameter: NetworkRequest?
    var invokedPerformRequestParametersList = [NetworkRequest]()
    var performRequestMethodStub = { (request: NetworkRequest, completion: @escaping PerformRequestCompletion) -> Cancellable in
        completion(.success(.stub()))
        return CancellableMock()
    }

    func performRequest(
        _ request: NetworkRequest,
        completion: @escaping (Result<NetworkResponse, NetworkError>) -> Void
    ) -> Cancellable {
        invokedPerformRequest = true
        invokedPerformRequestCount += 1
        invokedPerformRequestParameter = request
        invokedPerformRequestParametersList.append(request)
        return performRequestMethodStub(request, completion)
    }

    var invokedPerformRequestURLRequestCompletion = false
    var invokedPerformRequestURLRequestCompletionCount = 0
    var invokedPerformRequestURLRequestCompletionParameters: (urlRequest: URLRequest, Void)?
    var invokedPerformRequestURLRequestCompletionParametersList = [(urlRequest: URLRequest, Void)]()
    var performRequestURLRequestMethodStub = { (urlRequest: URLRequest, completion: @escaping PerformRequestCompletion) -> Cancellable in
        completion(.success(.stub()))
        return CancellableMock()
    }

    func performRequest(
        _ urlRequest: URLRequest,
        completion: @escaping (Result<NetworkResponse, NetworkError>) -> Void
    ) -> Cancellable {
        invokedPerformRequestURLRequestCompletion = true
        invokedPerformRequestURLRequestCompletionCount += 1
        invokedPerformRequestURLRequestCompletionParameters = (urlRequest, ())
        invokedPerformRequestURLRequestCompletionParametersList.append((urlRequest, ()))
        return performRequestURLRequestMethodStub(urlRequest, completion)
    }
}
