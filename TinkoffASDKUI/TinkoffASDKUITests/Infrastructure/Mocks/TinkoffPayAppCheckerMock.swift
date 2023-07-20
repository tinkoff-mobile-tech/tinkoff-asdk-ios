//
//  TinkoffPayAppCheckerMock.swift
//  TinkoffASDKUI-Unit-Tests
//
//  Created by Никита Васильев on 31.05.2023.
//

@testable import TinkoffASDKUI

final class TinkoffPayAppCheckerMock: ITinkoffPayAppChecker {

    // MARK: - isTinkoffPayAppInstalled

    var isTinkoffPayAppInstalledCallsCount = 0
    var isTinkoffPayAppInstalledReturnValue = false

    func isTinkoffPayAppInstalled() -> Bool {
        isTinkoffPayAppInstalledCallsCount += 1
        return isTinkoffPayAppInstalledReturnValue
    }
}

// MARK: - Resets

extension TinkoffPayAppCheckerMock {
    func fullReset() {
        isTinkoffPayAppInstalledCallsCount = 0
    }
}
