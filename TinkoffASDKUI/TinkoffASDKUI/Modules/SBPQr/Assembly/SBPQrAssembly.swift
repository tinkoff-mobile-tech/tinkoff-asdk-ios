//
//  SBPQrAssembly.swift
//  TinkoffASDKUI
//
//  Created by Aleksandr Pravosudov on 14.03.2023.
//

import TinkoffASDKCore
import UIKit

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
        let paymentStatusService = PaymentStatusService(paymentService: acquiringSdk)
        let repeatedRequestHelper = RepeatedRequestHelper()

        let presenter = SBPQrPresenter(
            sbpService: acquiringSdk,
            paymentFlow: paymentFlow,
            repeatedRequestHelper: repeatedRequestHelper,
            paymentStatusService: paymentStatusService,
            mainDispatchQueue: DispatchQueue.main,
            moduleCompletion: moduleCompletion
        )

        let tableContentProvider = SBPQrTableContentProvider()

        let view = SBPQrViewController(presenter: presenter, tableContentProvider: tableContentProvider)
        presenter.view = view

        let container = PullableContainerViewController(content: view)
        view.pullableContentDelegate = container

        return container
    }
}
