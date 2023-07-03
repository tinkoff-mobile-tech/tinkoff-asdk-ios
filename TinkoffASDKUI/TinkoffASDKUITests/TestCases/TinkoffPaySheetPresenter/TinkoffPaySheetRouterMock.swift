//
//  TinkoffPaySheetRouterMock.swift
//  TinkoffASDKUI-Unit-Tests
//
//  Created by Никита Васильев on 29.05.2023.
//

@testable import TinkoffASDKUI

final class TinkoffPaySheetRouterMock: ITinkoffPaySheetRouter {
    var invokedOpenTinkoffPayLanding = false
    var invokedOpenTinkoffPayLandingCount = 0
    var openTinkoffPayLandingCompletionShouldExecute = true
    func openTinkoffPayLanding(completion: TinkoffASDKUI.VoidBlock?) {
        invokedOpenTinkoffPayLanding = true
        invokedOpenTinkoffPayLandingCount += 1
        if openTinkoffPayLandingCompletionShouldExecute {
            completion?()
        }
    }
}
