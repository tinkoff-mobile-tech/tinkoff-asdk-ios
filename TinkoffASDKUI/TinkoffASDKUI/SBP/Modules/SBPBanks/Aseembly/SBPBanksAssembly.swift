//
//  SBPBanksAssembly.swift
//  TinkoffASDKUI
//
//  Created by Aleksandr Pravosudov on 21.12.2022.
//

import TinkoffASDKCore

final class SBPBanksAssembly: ISBPBanksAssembly {

    // Dependencies
    private let acquiringSdk: AcquiringSdk

    // MARK: - Initialization

    init(acquiringSdk: AcquiringSdk) {
        self.acquiringSdk = acquiringSdk
    }

    // MARK: - ISBPBanksAssembly

    func build() -> UIViewController {
        let banksService = SBPBanksServiceNew(acquiringSdk: acquiringSdk)
        let presenter = SBPBanksPresenter(banksService: banksService)

        let view = SBPBanksViewController(presenter: presenter)
        presenter.view = view
        return view
    }
}
