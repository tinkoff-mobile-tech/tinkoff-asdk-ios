//
//  AcquiringTerminalServiceMock.swift
//  TinkoffASDKYandexPay-Unit-Tests
//
//  Created by Ivan Glushko on 19.05.2023.
//

import TinkoffASDKCore
@testable import TinkoffASDKUI

final class AcquiringTerminalServiceMock: IAcquiringTerminalService {

    // MARK: - getTerminalPayMethods

    typealias GetTerminalPayMethodsArguments = (Result<GetTerminalPayMethodsPayload, Error>) -> Void

    var getTerminalPayMethodsCallsCount = 0
    var getTerminalPayMethodsReceivedArguments: GetTerminalPayMethodsArguments?
    var getTerminalPayMethodsReceivedInvocations: [GetTerminalPayMethodsArguments?] = []
    var getTerminalPayMethodsCompletionClosureInput: Result<GetTerminalPayMethodsPayload, Error>?
    var getTerminalPayMethodsReturnValue: Cancellable = CancellableMock()

    @discardableResult
    func getTerminalPayMethods(completion: @escaping (Result<GetTerminalPayMethodsPayload, Error>) -> Void) -> Cancellable {
        getTerminalPayMethodsCallsCount += 1
        let arguments = completion
        getTerminalPayMethodsReceivedArguments = arguments
        getTerminalPayMethodsReceivedInvocations.append(arguments)
        if let getTerminalPayMethodsCompletionClosureInput = getTerminalPayMethodsCompletionClosureInput {
            completion(getTerminalPayMethodsCompletionClosureInput)
        }
        return getTerminalPayMethodsReturnValue
    }
}

// MARK: - Resets

extension AcquiringTerminalServiceMock {
    func fullReset() {
        getTerminalPayMethodsCallsCount = 0
        getTerminalPayMethodsReceivedArguments = nil
        getTerminalPayMethodsReceivedInvocations = []
        getTerminalPayMethodsCompletionClosureInput = nil
    }
}
