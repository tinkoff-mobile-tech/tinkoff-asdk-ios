//
//  AppCheckerMock.swift
//  TinkoffASDKUI-Unit-Tests
//
//  Created by Aleksandr Pravosudov on 26.04.2023.
//

@testable import TinkoffASDKUI

final class AppCheckerMock: IAppChecker {

    // MARK: - checkApplication

    var checkApplicationCallsCount = 0
    var checkApplicationReceivedArguments: String?
    var checkApplicationReceivedInvocations: [String] = []
    var checkApplicationReturnValue: AppCheckingResult!

    func checkApplication(withScheme scheme: String) -> AppCheckingResult {
        checkApplicationCallsCount += 1
        let arguments = scheme
        checkApplicationReceivedArguments = arguments
        checkApplicationReceivedInvocations.append(arguments)
        return checkApplicationReturnValue
    }
}
