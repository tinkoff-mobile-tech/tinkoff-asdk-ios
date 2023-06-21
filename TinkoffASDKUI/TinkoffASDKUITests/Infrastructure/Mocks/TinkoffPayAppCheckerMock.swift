//
//  TinkoffPayAppCheckerMock.swift
//  TinkoffASDKUI-Unit-Tests
//
//  Created by Никита Васильев on 31.05.2023.
//

@testable import TinkoffASDKUI

final class TinkoffPayAppCheckerMock: ITinkoffPayAppChecker {
    var invokedIsTinkoffPayAppInstalled = false
    var invokedIsTinkoffPayAppInstalledCount = 0
    var stubbedIsTinkoffPayAppInstalled: Bool = false
    func isTinkoffPayAppInstalled() -> Bool {
        invokedIsTinkoffPayAppInstalled = true
        invokedIsTinkoffPayAppInstalledCount += 1
        return stubbedIsTinkoffPayAppInstalled
    }
}
