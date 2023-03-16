//
//  SBPQrAssembly.swift
//  TinkoffASDKUI
//
//  Created by Aleksandr Pravosudov on 14.03.2023.
//

import UIKit
import TinkoffASDKCore

final class SBPQrAssembly: ISBPQrAssembly {

    // MARK: Dependencies

    private let acquiringSdk: AcquiringSdk

    // MARK: Initialization

    init(acquiringSdk: AcquiringSdk) {
        self.acquiringSdk = acquiringSdk
    }

    // MARK: ISBPQrAssembly

    func buildForStaticQr(moduleCompletion: VoidBlock?) -> UIViewController {
        let paymentResultCompletion: PaymentResultCompletion = { _ in
            moduleCompletion?()
        }

        return build(paymentFlow: nil, moduleCompletion: paymentResultCompletion)
    }

    func buildForDynamicQr(paymentFlow: PaymentFlow, moduleCompletion: PaymentResultCompletion?) -> UIViewController {
        build(paymentFlow: paymentFlow, moduleCompletion: moduleCompletion)
    }
}

// MARK: - Private

extension SBPQrAssembly {
    private func build(paymentFlow: PaymentFlow?, moduleCompletion: PaymentResultCompletion?) -> UIViewController {
        let paymentStatusService = PaymentStatusService(acquiringSdk: acquiringSdk)
        let repeatedRequestHelper = RepeatedRequestHelper()

        let presenter = SBPQrPresenter(
            acquiringSdk: acquiringSdk,
            paymentFlow: paymentFlow,
            repeatedRequestHelper: repeatedRequestHelper,
            paymentStatusService: paymentStatusService,
            moduleCompletion: moduleCompletion
        )
        let view = SBPQrViewController(presenter: presenter)
        presenter.view = view

        let pullableContainerViewController = PullableContainerViewController(content: view)
        return pullableContainerViewController
    }
}
