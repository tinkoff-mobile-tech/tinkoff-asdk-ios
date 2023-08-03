//
//  HTTPStatusCodeValidatorMock.swift
//  TinkoffASDKCore-Unit-Tests
//
//  Created by r.akhmadeev on 10.10.2022.
//

import Foundation
@testable import TinkoffASDKCore

final class HTTPStatusCodeValidatorMock: IHTTPStatusCodeValidator {

    // MARK: - validate

    typealias ValidateArguments = Int

    var validateCallsCount = 0
    var validateReceivedArguments: ValidateArguments?
    var validateReceivedInvocations: [ValidateArguments?] = []
    var validateReturnValue = true

    func validate(statusCode: Int) -> Bool {
        validateCallsCount += 1
        let arguments = statusCode
        validateReceivedArguments = arguments
        validateReceivedInvocations.append(arguments)
        return validateReturnValue
    }
}

// MARK: - Resets

extension HTTPStatusCodeValidatorMock {
    func fullReset() {
        validateCallsCount = 0
        validateReceivedArguments = nil
        validateReceivedInvocations = []
    }
}
