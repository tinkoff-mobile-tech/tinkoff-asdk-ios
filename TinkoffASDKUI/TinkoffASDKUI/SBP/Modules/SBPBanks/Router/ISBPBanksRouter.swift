//
//  ISBPBanksRouter.swift
//  TinkoffASDKUI
//
//  Created by Aleksandr Pravosudov on 26.12.2022.
//

import TinkoffASDKCore

protocol ISBPBanksRouter {
    func closeScreen()
    func show(banks: [SBPBank])
}
