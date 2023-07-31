//
//  AppCheckerMock.swift
//  TinkoffASDKUI-Unit-Tests
//
//  Created by Aleksandr Pravosudov on 26.04.2023.
//

@testable import TinkoffASDKUI

final class AppCheckerMock: IAppChecker {

    // MARK: - checkApplication

    typealias CheckApplicationArguments = String

    var checkApplicationCallsCount = 0
    var checkApplicationReceivedArguments: CheckApplicationArguments?
    var checkApplicationReceivedInvocations: [CheckApplicationArguments?] = []
    var checkApplicationReturnValue: AppCheckingResult!

    func checkApplication(withScheme scheme: String) -> AppCheckingResult {
        checkApplicationCallsCount += 1
        let arguments = scheme
        checkApplicationReceivedArguments = arguments
        checkApplicationReceivedInvocations.append(arguments)
        return checkApplicationReturnValue
    }
}

// MARK: - Resets

extension AppCheckerMock {
    func fullReset() {
        checkApplicationCallsCount = 0
        checkApplicationReceivedArguments = nil
        checkApplicationReceivedInvocations = []
    }
}
