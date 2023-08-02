//
//  CertificateValidatorMock.swift
//  TinkoffASDKCore-Unit-Tests
//
//  Created by Никита Васильев on 31.07.2023.
//

import Foundation
@testable import TinkoffASDKCore

public final class CertificateValidatorMock: ICertificateValidator {
    public init() {}

    // MARK: - isValid

    public typealias IsValidArguments = SecTrust

    public var isValidCallsCount = 0
    public var isValidReceivedArguments: IsValidArguments?
    public var isValidReceivedInvocations: [IsValidArguments?] = []
    public var isValidReturnValue: Bool!

    public func isValid(serverTrust: SecTrust) -> Bool {
        isValidCallsCount += 1
        let arguments = serverTrust
        isValidReceivedArguments = arguments
        isValidReceivedInvocations.append(arguments)
        return isValidReturnValue
    }
}

// MARK: - Resets

extension CertificateValidatorMock {
    func fullReset() {
        isValidCallsCount = 0
        isValidReceivedArguments = nil
        isValidReceivedInvocations = []
    }
}
