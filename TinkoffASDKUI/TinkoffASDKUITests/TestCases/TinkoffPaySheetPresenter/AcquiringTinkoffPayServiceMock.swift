//
//  AcquiringTinkoffPayServiceMock.swift
//  TinkoffASDKUI-Unit-Tests
//
//  Created by Никита Васильев on 29.05.2023.
//

import Foundation
import TinkoffASDKCore
@testable import TinkoffASDKUI

final class AcquiringTinkoffPayServiceMock: IAcquiringTinkoffPayService {

    // MARK: - getTinkoffPayLink

    typealias GetTinkoffPayLinkArguments = (data: GetTinkoffLinkData, completion: (Result<GetTinkoffLinkPayload, Error>) -> Void)

    var getTinkoffPayLinkCallsCount = 0
    var getTinkoffPayLinkReceivedArguments: GetTinkoffPayLinkArguments?
    var getTinkoffPayLinkReceivedInvocations: [GetTinkoffPayLinkArguments] = []
    var getTinkoffPayLinkCompletionClosureInput: Result<GetTinkoffLinkPayload, Error>?
    var getTinkoffPayLinkReturnValue: Cancellable = CancellableMock()

    @discardableResult
    func getTinkoffPayLink(data: GetTinkoffLinkData, completion: @escaping (Result<GetTinkoffLinkPayload, Error>) -> Void) -> Cancellable {
        getTinkoffPayLinkCallsCount += 1
        let arguments = (data, completion)
        getTinkoffPayLinkReceivedArguments = arguments
        getTinkoffPayLinkReceivedInvocations.append(arguments)
        if let getTinkoffPayLinkCompletionClosureInput = getTinkoffPayLinkCompletionClosureInput {
            completion(getTinkoffPayLinkCompletionClosureInput)
        }
        return getTinkoffPayLinkReturnValue
    }

    // MARK: - getTinkoffPayStatus

    typealias GetTinkoffPayStatusArguments = (Result<GetTinkoffPayStatusPayload, Error>) -> Void

    var getTinkoffPayStatusCallsCount = 0
    var getTinkoffPayStatusReceivedArguments: GetTinkoffPayStatusArguments?
    var getTinkoffPayStatusReceivedInvocations: [GetTinkoffPayStatusArguments] = []
    var getTinkoffPayStatusCompletionClosureInput: Result<GetTinkoffPayStatusPayload, Error>?
    var getTinkoffPayStatusReturnValue: Cancellable = CancellableMock()

    @discardableResult
    func getTinkoffPayStatus(completion: @escaping (Result<GetTinkoffPayStatusPayload, Error>) -> Void) -> Cancellable {
        getTinkoffPayStatusCallsCount += 1
        let arguments = completion
        getTinkoffPayStatusReceivedArguments = arguments
        getTinkoffPayStatusReceivedInvocations.append(arguments)
        if let getTinkoffPayStatusCompletionClosureInput = getTinkoffPayStatusCompletionClosureInput {
            completion(getTinkoffPayStatusCompletionClosureInput)
        }
        return getTinkoffPayStatusReturnValue
    }
}

// MARK: - Resets

extension AcquiringTinkoffPayServiceMock {
    func fullReset() {
        getTinkoffPayLinkCallsCount = 0
        getTinkoffPayLinkReceivedArguments = nil
        getTinkoffPayLinkReceivedInvocations = []
        getTinkoffPayLinkCompletionClosureInput = nil

        getTinkoffPayStatusCallsCount = 0
        getTinkoffPayStatusReceivedArguments = nil
        getTinkoffPayStatusReceivedInvocations = []
        getTinkoffPayStatusCompletionClosureInput = nil
    }
}
