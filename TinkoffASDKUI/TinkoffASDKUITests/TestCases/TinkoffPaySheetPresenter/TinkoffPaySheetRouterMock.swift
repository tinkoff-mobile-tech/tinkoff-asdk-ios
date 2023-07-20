//
//  TinkoffPaySheetRouterMock.swift
//  TinkoffASDKUI-Unit-Tests
//
//  Created by Никита Васильев on 29.05.2023.
//

@testable import TinkoffASDKUI

final class TinkoffPaySheetRouterMock: ITinkoffPaySheetRouter {

    // MARK: - openTinkoffPayLanding

    typealias OpenTinkoffPayLandingArguments = VoidBlock

    var openTinkoffPayLandingCallsCount = 0
    var openTinkoffPayLandingReceivedArguments: OpenTinkoffPayLandingArguments?
    var openTinkoffPayLandingReceivedInvocations: [OpenTinkoffPayLandingArguments?] = []
    var openTinkoffPayLandingCompletionShouldExecute = false

    func openTinkoffPayLanding(completion: VoidBlock?) {
        openTinkoffPayLandingCallsCount += 1
        let arguments = completion
        openTinkoffPayLandingReceivedArguments = arguments
        openTinkoffPayLandingReceivedInvocations.append(arguments)
        if openTinkoffPayLandingCompletionShouldExecute {
            completion?()
        }
    }
}

// MARK: - Resets

extension TinkoffPaySheetRouterMock {
    func fullReset() {
        openTinkoffPayLandingCallsCount = 0
        openTinkoffPayLandingReceivedArguments = nil
        openTinkoffPayLandingReceivedInvocations = []
        openTinkoffPayLandingCompletionShouldExecute = false
    }
}
