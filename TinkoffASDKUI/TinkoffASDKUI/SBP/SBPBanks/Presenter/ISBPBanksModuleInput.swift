//
//  ISBPBanksModuleInput.swift
//  TinkoffASDKUI
//
//  Created by Aleksandr Pravosudov on 26.12.2022.
//

import TinkoffASDKCore

protocol ISBPBanksModuleInput {
    func set(qrPayload: GetQRPayload?, banks: [SBPBank])
}
