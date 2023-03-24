//
//  ISBPBanksModuleOutput.swift
//  TinkoffASDKUI
//
//  Created by Aleksandr Pravosudov on 01.03.2023.

import TinkoffASDKCore

protocol ISBPBanksModuleOutput: AnyObject {
    func didLoaded(sbpBanks: [SBPBank])
}
