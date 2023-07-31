//
//  AcquiringAPIClientMock.swift
//  TinkoffASDKCore-Unit-Tests
//
//  Created by Никита Васильев on 26.07.2023.
//

@testable import TinkoffASDKCore

final class AcquiringAPIClientMock<GenericPayload: Decodable>: IAcquiringAPIClient {

    // MARK: - performRequest<Payload Decodable>

    typealias PerformRequestArguments = (request: AcquiringRequest, completion: (Result<GenericPayload, Error>) -> Void)
    typealias Completion = (Result<GenericPayload, Error>) -> Void

    var performRequestCallsCount = 0
    var performRequestReceivedArguments: PerformRequestArguments?
    var performRequestReceivedInvocations: [PerformRequestArguments?] = []
    var performRequestCompletionClosureInput: Result<GenericPayload, Error>?
    var performRequestReturnValue: Cancellable = CancellableMock()

    func performRequest<Payload: Decodable>(_ request: AcquiringRequest, completion: @escaping (Result<Payload, Error>) -> Void) -> Cancellable {
        performRequestCallsCount += 1
        let arguments = (request, completion as! Completion)
        performRequestReceivedArguments = arguments
        performRequestReceivedInvocations.append(arguments)
        return performRequestReturnValue
    }
}

// MARK: - Resets

extension AcquiringAPIClientMock {
    func fullReset() {
        performRequestCallsCount = 0
        performRequestReceivedArguments = nil
        performRequestReceivedInvocations = []
        performRequestCompletionClosureInput = nil
    }
}
