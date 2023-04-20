//
//  SBPBankAppCheckerMock.swift
//  TinkoffASDKUI-Unit-Tests
//
//  Created by Aleksandr Pravosudov on 20.04.2023.
//

import TinkoffASDKCore
@testable import TinkoffASDKUI

final class SBPBankAppCheckerMock: ISBPBankAppChecker {

    // MARK: - bankAppsPreferredByMerchant

    var bankAppsPreferredByMerchantCallsCount = 0
    var bankAppsPreferredByMerchantReceivedArguments: [SBPBank]?
    var bankAppsPreferredByMerchantReceivedInvocations: [[SBPBank]] = []
    var bankAppsPreferredByMerchantReturnValue: [SBPBank]!

    func bankAppsPreferredByMerchant(from allBanks: [SBPBank]) -> [SBPBank] {
        bankAppsPreferredByMerchantCallsCount += 1
        let arguments = allBanks
        bankAppsPreferredByMerchantReceivedArguments = arguments
        bankAppsPreferredByMerchantReceivedInvocations.append(arguments)
        return bankAppsPreferredByMerchantReturnValue
    }
}
