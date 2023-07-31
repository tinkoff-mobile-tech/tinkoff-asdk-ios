//
//  RepeatedRequestHelperMock.swift
//  TinkoffASDKUI-Unit-Tests
//
//  Created by Aleksandr Pravosudov on 28.04.2023.
//

import TinkoffASDKCore
@testable import TinkoffASDKUI

final class RepeatedRequestHelperMock: IRepeatedRequestHelper {

    // MARK: - executeWithWaitingIfNeeded

    typealias ExecuteWithWaitingIfNeededArguments = () -> Void

    var executeWithWaitingIfNeededCallsCount = 0
    var executeWithWaitingIfNeededReceivedArguments: ExecuteWithWaitingIfNeededArguments?
    var executeWithWaitingIfNeededReceivedInvocations: [ExecuteWithWaitingIfNeededArguments?] = []
    var executeWithWaitingIfNeededActionShouldExecute = false

    func executeWithWaitingIfNeeded(action: @escaping () -> Void) {
        executeWithWaitingIfNeededCallsCount += 1
        let arguments = action
        executeWithWaitingIfNeededReceivedArguments = arguments
        executeWithWaitingIfNeededReceivedInvocations.append(arguments)
        if executeWithWaitingIfNeededActionShouldExecute {
            action()
        }
    }
}

// MARK: - Resets

extension RepeatedRequestHelperMock {
    func fullReset() {
        executeWithWaitingIfNeededCallsCount = 0
        executeWithWaitingIfNeededReceivedArguments = nil
        executeWithWaitingIfNeededReceivedInvocations = []
        executeWithWaitingIfNeededActionShouldExecute = false
    }
}
