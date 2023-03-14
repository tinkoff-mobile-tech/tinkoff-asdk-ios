//
//  SBPQrAssembly.swift
//  TinkoffASDKUI
//
//  Created by Aleksandr Pravosudov on 14.03.2023.
//

import TinkoffASDKCore

final class SBPQrAssembly: ISBPQrAssembly {

    // MARK: Dependencies

    private let acquiringSdk: AcquiringSdk

    // MARK: Initialization

    init(acquiringSdk: AcquiringSdk) {
        self.acquiringSdk = acquiringSdk
    }

    // MARK: ISBPQrAssembly

    func buildForStaticQr(moduleCompletion: PaymentResultCompletion?) -> UIViewController {
        build(paymentFlow: nil, moduleCompletion: moduleCompletion)
    }

    func buildForDynamicQr(paymentFlow: PaymentFlow, moduleCompletion: PaymentResultCompletion?) -> UIViewController {
        build(paymentFlow: paymentFlow, moduleCompletion: moduleCompletion)
    }
}

// MARK: - Private

extension SBPQrAssembly {
    private func build(paymentFlow: PaymentFlow?, moduleCompletion: PaymentResultCompletion?) -> UIViewController {
        let presenter = SBPQrPresenter(
            acquiringSdk: acquiringSdk,
            paymentFlow: paymentFlow,
            moduleCompletion: moduleCompletion
        )
        let view = SBPQrViewController(presenter: presenter)
        presenter.view = view

        let pullableContainerViewController = PullableContainerViewController(content: view)
        return pullableContainerViewController
    }
}
