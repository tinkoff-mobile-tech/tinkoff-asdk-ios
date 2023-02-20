//
//  SBPBanksAssembly.swift
//  TinkoffASDKUI
//
//  Created by Aleksandr Pravosudov on 21.12.2022.
//

import TinkoffASDKCore
import UIKit

typealias SBPBanksModule = Module<ISBPBanksModuleInput>

final class SBPBanksAssembly: ISBPBanksAssembly {

    // Dependencies
    private let acquiringSdk: AcquiringSdk
    private let sbpConfiguration: SBPConfiguration

    // MARK: - Initialization

    init(
        acquiringSdk: AcquiringSdk,
        sbpConfiguration: SBPConfiguration
    ) {
        self.acquiringSdk = acquiringSdk
        self.sbpConfiguration = sbpConfiguration
    }

    // MARK: - ISBPBanksAssembly

    func buildPreparedModule(paymentSheetOutput: ISBPPaymentSheetPresenterOutput?) -> SBPBanksModule {
        build(paymentService: nil, paymentSheetOutput: paymentSheetOutput)
    }

    func buildInitialModule(
        paymentFlow: PaymentFlow,
        paymentSheetOutput: ISBPPaymentSheetPresenterOutput?
    ) -> SBPBanksModule {
        let paymentService = SBPPaymentServiceNew(
            acquiringSdk: acquiringSdk,
            paymentFlow: paymentFlow
        )
        return build(paymentService: paymentService, paymentSheetOutput: paymentSheetOutput)
    }
}

// MARK: - Private

extension SBPBanksAssembly {
    private func build(paymentService: SBPPaymentServiceNew?, paymentSheetOutput: ISBPPaymentSheetPresenterOutput?) -> SBPBanksModule {
        let sbpPaymentSheetAssembly = SBPPaymentSheetAssembly(
            acquiringSdk: acquiringSdk,
            sbpConfiguration: sbpConfiguration
        )
        let router = SBPBanksRouter(sbpBanksAssembly: self, sbpPaymentSheetAssembly: sbpPaymentSheetAssembly)

        let banksService = SBPBanksServiceNew(acquiringSdk: acquiringSdk)
        let bankAppChecker = SBPBankAppChecker(application: UIApplication.shared)
        let bankAppOpener = SBPBankAppOpener(application: UIApplication.shared)

        let cellImageLoader = CellImageLoader(imageLoader: ImageLoader(urlDataLoader: acquiringSdk))
        cellImageLoader.set(type: .roundAndSize(.logoImageSize))
        let cellPresentersAssembly = SBPBankCellPresenterNewAssembly(cellImageLoader: cellImageLoader)

        let presenter = SBPBanksPresenter(
            router: router,
            paymentSheetOutput: paymentSheetOutput,
            paymentService: paymentService,
            banksService: banksService,
            bankAppChecker: bankAppChecker,
            bankAppOpener: bankAppOpener,
            cellPresentersAssembly: cellPresentersAssembly,
            dispatchGroup: DispatchGroup()
        )

        let view = SBPBanksViewController(presenter: presenter)
        presenter.view = view
        router.transitionHandler = view
        return Module(view: view, input: presenter)
    }
}

// MARK: - Constants

private extension CGSize {
    static let logoImageSize = CGSize(width: 40, height: 40)
}
