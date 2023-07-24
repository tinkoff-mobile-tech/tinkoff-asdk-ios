//
//  SBPBanksModuleOutputMock.swift
//  TinkoffASDKUI-Unit-Tests
//
//  Created by Aleksandr Pravosudov on 20.04.2023.
//

import TinkoffASDKCore
@testable import TinkoffASDKUI

final class SBPBanksModuleOutputMock: ISBPBanksModuleOutput {

    // MARK: - didLoaded

    typealias DidLoadedArguments = [SBPBank]

    var didLoadedCallsCount = 0
    var didLoadedReceivedArguments: DidLoadedArguments?
    var didLoadedReceivedInvocations: [DidLoadedArguments?] = []

    func didLoaded(sbpBanks: [SBPBank]) {
        didLoadedCallsCount += 1
        let arguments = sbpBanks
        didLoadedReceivedArguments = arguments
        didLoadedReceivedInvocations.append(arguments)
    }
}

// MARK: - Resets

extension SBPBanksModuleOutputMock {
    func fullReset() {
        didLoadedCallsCount = 0
        didLoadedReceivedArguments = nil
        didLoadedReceivedInvocations = []
    }
}
