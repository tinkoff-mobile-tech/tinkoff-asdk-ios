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

    var getTerminalPayMethodsCallsCount = 0
    var getTerminalPayMethodsReceivedArguments: ((Result<GetTerminalPayMethodsPayload, Error>) -> Void)?
    var getTerminalPayMethodsReceivedInvocations: [(Result<GetTerminalPayMethodsPayload, Error>) -> Void] = []
    var getTerminalPayMethodsCompletionClosureInput: Result<GetTerminalPayMethodsPayload, Error>?
    var getTerminalPayMethodsReturnValue: Cancellable!

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
