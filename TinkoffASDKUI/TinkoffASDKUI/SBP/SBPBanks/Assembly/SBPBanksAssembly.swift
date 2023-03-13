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
        build(paymentService: nil, output: nil, paymentSheetOutput: paymentSheetOutput, completion: nil)
    }

    func buildInitialModule(
        paymentFlow: PaymentFlow,
        completion: PaymentResultCompletion?
    ) -> SBPBanksModule {
        let paymentService = SBPPaymentService(
            acquiringSdk: acquiringSdk,
            paymentFlow: paymentFlow
        )

        return build(paymentService: paymentService, output: nil, paymentSheetOutput: nil, completion: completion)
    }

    func buildInitialModule(
        paymentFlow: PaymentFlow,
        output: ISBPBanksModuleOutput?,
        paymentSheetOutput: ISBPPaymentSheetPresenterOutput?
    ) -> SBPBanksModule {
        let paymentService = SBPPaymentService(
            acquiringSdk: acquiringSdk,
            paymentFlow: paymentFlow
        )
        return build(paymentService: paymentService, output: output, paymentSheetOutput: paymentSheetOutput, completion: nil)
    }
}

// MARK: - Private

extension SBPBanksAssembly {
    private func build(
        paymentService: SBPPaymentService?,
        output: ISBPBanksModuleOutput?,
        paymentSheetOutput: ISBPPaymentSheetPresenterOutput?,
        completion: PaymentResultCompletion?
    ) -> SBPBanksModule {
        let sbpPaymentSheetAssembly = SBPPaymentSheetAssembly(
            acquiringSdk: acquiringSdk,
            sbpConfiguration: sbpConfiguration
        )
        let router = SBPBanksRouter(sbpBanksAssembly: self, sbpPaymentSheetAssembly: sbpPaymentSheetAssembly)

        let banksService = SBPBanksService(acquiringSdk: acquiringSdk)
        let bankAppChecker = SBPBankAppChecker(appChecker: AppChecker())
        let bankAppOpener = SBPBankAppOpener(application: UIApplication.shared)

        let cellImageLoader = CellImageLoader(imageLoader: ImageLoader(urlDataLoader: acquiringSdk))
        cellImageLoader.set(type: .roundAndSize(.logoImageSize))
        let cellPresentersAssembly = SBPBankCellPresenterAssembly(cellImageLoader: cellImageLoader)

        let presenter = SBPBanksPresenter(
            router: router,
            output: output,
            paymentSheetOutput: paymentSheetOutput,
            moduleCompletion: completion,
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
