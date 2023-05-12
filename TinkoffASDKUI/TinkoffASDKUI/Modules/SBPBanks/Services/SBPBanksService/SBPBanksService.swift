//
//  SBPBanksService.swift
//  TinkoffASDKUI
//
//  Created by Aleksandr Pravosudov on 21.12.2022.
//

import TinkoffASDKCore

final class SBPBanksService: ISBPBanksService {

    // Dependencies
    private let acquiringSBPService: IAcquiringSBPService

    // MARK: - Initialization

    init(acquiringSBPService: IAcquiringSBPService) {
        self.acquiringSBPService = acquiringSBPService
    }

    // MARK: - ISBPBanksService

    /// Загружает список банков с NSPK (Национальная система платёжных карт)
    /// - Parameter completion: В случае success выдает массив банков
    func loadBanks(completion: @escaping SBPBanksServiceLoadBanksCompletion) {
        acquiringSBPService.loadSBPBanks { completion($0.map(\.banks)) }
    }
}
