//
//  NetworkClientMock.swift
//  TinkoffASDKCore-Unit-Tests
//
//  Created by r.akhmadeev on 24.10.2022.
//

import Foundation
@testable import TinkoffASDKCore

final class NetworkClientMock: INetworkClient {

    // MARK: - performRequest

    typealias PerformRequestArguments = (request: NetworkRequest, completion: (Result<NetworkResponse, NetworkError>) -> Void)

    var performRequestCallsCount = 0
    var performRequestReceivedArguments: PerformRequestArguments?
    var performRequestReceivedInvocations: [PerformRequestArguments?] = []
    var performRequestCompletionClosure: ((@escaping (Result<NetworkResponse, NetworkError>) -> Void) -> Void)?
    var performRequestCompletionClosureInput: Result<NetworkResponse, NetworkError>? = .success(.stub())
    var performRequestReturnValue: Cancellable = CancellableMock()

    @discardableResult
    func performRequest(_ request: NetworkRequest, completion: @escaping (Result<NetworkResponse, NetworkError>) -> Void) -> Cancellable {
        performRequestCallsCount += 1
        let arguments = (request, completion)
        performRequestReceivedArguments = arguments
        performRequestReceivedInvocations.append(arguments)
        if let performRequestCompletionClosure = performRequestCompletionClosure {
            performRequestCompletionClosure(completion)
        } else if let performRequestCompletionClosureInput = performRequestCompletionClosureInput {
            completion(performRequestCompletionClosureInput)
        }
        return performRequestReturnValue
    }

    // MARK: - performUrlRequest

    typealias PerformUrlRequestArguments = (urlRequest: URLRequest, completion: (Result<NetworkResponse, NetworkError>) -> Void)

    var performUrlRequestCallsCount = 0
    var performUrlRequestReceivedArguments: PerformUrlRequestArguments?
    var performUrlRequestReceivedInvocations: [PerformUrlRequestArguments?] = []
    var performUrlRequestCompletionClosureInput: Result<NetworkResponse, NetworkError>? = .success(.stub())
    var performUrlRequestReturnValue: Cancellable = CancellableMock()

    @discardableResult
    func performRequest(_ urlRequest: URLRequest, completion: @escaping (Result<NetworkResponse, NetworkError>) -> Void) -> Cancellable {
        performUrlRequestCallsCount += 1
        let arguments = (urlRequest, completion)
        performUrlRequestReceivedArguments = arguments
        performUrlRequestReceivedInvocations.append(arguments)
        if let performUrlRequestCompletionClosureInput = performUrlRequestCompletionClosureInput {
            completion(performUrlRequestCompletionClosureInput)
        }
        return performUrlRequestReturnValue
    }
}

// MARK: - Resets

extension NetworkClientMock {
    func fullReset() {
        performRequestCallsCount = 0
        performRequestReceivedArguments = nil
        performRequestReceivedInvocations = []
        performRequestCompletionClosureInput = nil

        performUrlRequestCallsCount = 0
        performUrlRequestReceivedArguments = nil
        performUrlRequestReceivedInvocations = []
        performUrlRequestCompletionClosureInput = nil
    }
}
