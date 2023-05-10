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

    var didLoadedCallsCount = 0
    var didLoadedReceivedArguments: [SBPBank]?
    var didLoadedReceivedInvocations: [[SBPBank]] = []

    func didLoaded(sbpBanks: [SBPBank]) {
        didLoadedCallsCount += 1
        let arguments = sbpBanks
        didLoadedReceivedArguments = arguments
        didLoadedReceivedInvocations.append(arguments)
    }
}
