//
//  RepeatedRequestHelperMock.swift
//  Pods
//
//  Created by Ivan Glushko on 06.06.2023.
//

@testable import TinkoffASDKUI

final class RepeatedRequestHelperMock: IRepeatedRequestHelper {

    // MARK: - executeWithWaitingIfNeeded

    var executeWithWaitingIfNeededCallsCount = 0
    var executeWithWaitingIfNeededReceivedArguments: () -> Void?
    var executeWithWaitingIfNeededReceivedInvocations: [() -> Void] = []
    var executeWithWaitingIfNeededActionClosureInput: ()?

    func executeWithWaitingIfNeeded(action: @escaping () -> Void) {
        executeWithWaitingIfNeededCallsCount += 1
        let arguments = action
        executeWithWaitingIfNeededReceivedArguments = arguments
        executeWithWaitingIfNeededReceivedInvocations.append(arguments)
        if let executeWithWaitingIfNeededActionClosureInput = executeWithWaitingIfNeededActionClosureInput {
            action(executeWithWaitingIfNeededActionClosureInput)
        }
    }
}
