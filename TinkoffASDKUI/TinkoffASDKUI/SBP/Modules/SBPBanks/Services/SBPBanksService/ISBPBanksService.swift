//
//  ISBPBanksService.swift
//  TinkoffASDKUI
//
//  Created by Aleksandr Pravosudov on 21.12.2022.
//

import TinkoffASDKCore

typealias SBPBanksServiceLoadBanksCompletion = (Result<[SBPBank], Error>) -> Void

protocol ISBPBanksService {
    func loadBanks(completion: @escaping SBPBanksServiceLoadBanksCompletion)
}
