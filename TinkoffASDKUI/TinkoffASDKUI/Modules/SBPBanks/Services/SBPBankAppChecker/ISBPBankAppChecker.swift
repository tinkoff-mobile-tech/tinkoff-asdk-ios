//
//  ISBPBankAppChecker.swift
//  TinkoffASDKUI
//
//  Created by Aleksandr Pravosudov on 23.12.2022.
//

import TinkoffASDKCore

protocol ISBPBankAppChecker {
    func bankAppsPreferredByMerchant(from allBanks: [SBPBank]) -> [SBPBank]
}
