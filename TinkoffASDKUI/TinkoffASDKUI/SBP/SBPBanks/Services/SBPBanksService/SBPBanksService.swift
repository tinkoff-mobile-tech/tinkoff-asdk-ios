//
//  SBPBanksService.swift
//  TinkoffASDKUI
//
//  Created by Aleksandr Pravosudov on 21.12.2022.
//

import TinkoffASDKCore

final class SBPBanksService: ISBPBanksService {

    // Dependencies
    private let acquiringSdk: AcquiringSdk

    // MARK: - Initialization

    init(acquiringSdk: AcquiringSdk) {
        self.acquiringSdk = acquiringSdk
    }

    // MARK: - ISBPBanksService

    /// Загружает список банков с NSPK (Национальная система платёжных карт)
    /// - Parameter completion: В случае success выдает массив банков
    func loadBanks(completion: @escaping SBPBanksServiceLoadBanksCompletion) {
        acquiringSdk.loadSBPBanks { completion($0.map(\.banks)) }
    }
}
