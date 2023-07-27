//
//  EmailValidatorMock.swift
//  TinkoffASDKCore-Unit-Tests
//
//  Created by Ivan Glushko on 27.07.2023.
//

import TinkoffASDKCore

public final class EmailValidatorMock: IEmailValidator {

    // MARK: - isValid

    typealias IsValidArguments = String

    var isValidCallsCount = 0
    var isValidReceivedArguments: IsValidArguments?
    var isValidReceivedInvocations: [IsValidArguments?] = []
    var isValidReturnValue: Bool = true

    public func isValid(_ email: String?) -> Bool {
        isValidCallsCount += 1
        let arguments = email
        isValidReceivedArguments = arguments
        isValidReceivedInvocations.append(arguments)
        return isValidReturnValue
    }
}

// MARK: - Resets

extension EmailValidatorMock {
    func fullReset() {
        isValidCallsCount = 0
        isValidReceivedArguments = nil
        isValidReceivedInvocations = []
    }
}
