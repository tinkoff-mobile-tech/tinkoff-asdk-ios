//
//  AcquiringRequestAdapterMock.swift
//  TinkoffASDKCore-Unit-Tests
//
//  Created by r.akhmadeev on 24.10.2022.
//

import Foundation
@testable import TinkoffASDKCore

final class AcquiringRequestAdapterMock: IAcquiringRequestAdapter {

    // MARK: - adapt

    typealias AdaptArguments = (request: AcquiringRequest, completion: (Result<AcquiringRequest, Error>) -> Void)

    var adaptCallsCount = 0
    var adaptReceivedArguments: AdaptArguments?
    var adaptReceivedInvocations: [AdaptArguments?] = []
    var adaptCompletionClosure: ((@escaping (Result<AcquiringRequest, Error>) -> Void) -> Void)?
    var adaptCompletionClosureInput: Result<AcquiringRequest, Error>? = .success(AcquiringRequestStub())

    func adapt(request: AcquiringRequest, completion: @escaping (Result<AcquiringRequest, Error>) -> Void) {
        adaptCallsCount += 1
        let arguments = (request, completion)
        adaptReceivedArguments = arguments
        adaptReceivedInvocations.append(arguments)
        if let adaptCompletionClosure = adaptCompletionClosure {
            adaptCompletionClosure(completion)
        } else if let adaptCompletionClosureInput = adaptCompletionClosureInput {
            completion(adaptCompletionClosureInput)
        }
    }
}

// MARK: - Resets

extension AcquiringRequestAdapterMock {
    func fullReset() {
        adaptCallsCount = 0
        adaptReceivedArguments = nil
        adaptReceivedInvocations = []
        adaptCompletionClosureInput = nil
    }
}
