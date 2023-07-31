//
//  ExternalAPIClientMock.swift
//  TinkoffASDKCore-Unit-Tests
//
//  Created by Никита Васильев on 26.07.2023.
//

import Foundation
@testable import TinkoffASDKCore

final class ExternalAPIClientMock<GenericPayload: Decodable>: IExternalAPIClient {

    // MARK: - perform<Payload Decodable>

    typealias PerformArguments = (request: NetworkRequest, completion: (Result<GenericPayload, Error>) -> Void)
    typealias Completion = (Result<GenericPayload, Error>) -> Void

    var performCallsCount = 0
    var performReceivedArguments: PerformArguments?
    var performReceivedInvocations: [PerformArguments?] = []
    var performCompletionClosureInput: Result<GenericPayload, Error>?
    var performReturnValue: Cancellable = CancellableMock()

    func perform<Payload: Decodable>(_ request: NetworkRequest, completion: @escaping (Result<Payload, Error>) -> Void) -> Cancellable {
        performCallsCount += 1
        let arguments = (request, completion as! Completion)
        performReceivedArguments = arguments
        performReceivedInvocations.append(arguments)
        return performReturnValue
    }
}

// MARK: - Resets

extension ExternalAPIClientMock {
    func fullReset() {
        performCallsCount = 0
        performReceivedArguments = nil
        performReceivedInvocations = []
        performCompletionClosureInput = nil
    }
}
