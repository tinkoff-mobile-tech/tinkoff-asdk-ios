//
//  ISBPBankAppChecker.swift
//  TinkoffASDKUI
//
//  Created by Aleksandr Pravosudov on 23.12.2022.
//

import TinkoffASDKCore

typealias SBPBankAppCheckerOpenBankAppCompletion = (Bool) -> Void

protocol ISBPBankAppChecker {
    func bankAppsPreferredByMerchant(from allBanks: [SBPBank]) -> [SBPBank]
    func openBankApp(_ bank: SBPBank, completion: @escaping SBPBankAppCheckerOpenBankAppCompletion)
}
