//
//  SBPBanksAssembly.swift
//  TinkoffASDKUI
//
//  Created by Aleksandr Pravosudov on 21.12.2022.
//

import TinkoffASDKCore

typealias SBPBanksModule = Module<ISBPBanksModuleInput>

final class SBPBanksAssembly: ISBPBanksAssembly {

    // Dependencies
    private let acquiringSdk: AcquiringSdk

    // MARK: - Initialization

    init(acquiringSdk: AcquiringSdk) {
        self.acquiringSdk = acquiringSdk
    }

    // MARK: - ISBPBanksAssembly

    func build() -> SBPBanksModule {
        let router = SBPBanksRouter(sbpBanksAssembly: self)

        let banksService = SBPBanksServiceNew(acquiringSdk: acquiringSdk)
        let bankAppChecker = SBPBankAppChecker(application: UIApplication.shared)
        let cellImageLoader = CellImageLoader.loader

        let presenter = SBPBanksPresenter(
            router: router,
            banksService: banksService,
            bankAppChecker: bankAppChecker,
            cellImageLoader: cellImageLoader
        )

        let view = SBPBanksViewController(presenter: presenter)
        presenter.view = view
        router.transitionHandler = view
        return Module(view: view, input: presenter)
    }
}
