//
//  RecurrentPaymentAssembly.swift
//  TinkoffASDKUI
//
//  Created by Aleksandr Pravosudov on 03.03.2023.
//

import TinkoffASDKCore
import UIKit

final class RecurrentPaymentAssembly: IRecurrentPaymentAssembly {

    // MARK: Dependencies

    private let acquiringSdk: AcquiringSdk
    private let paymentControllerAssembly: IPaymentControllerAssembly

    // MARK: Initialization

    init(
        acquiringSdk: AcquiringSdk,
        paymentControllerAssembly: IPaymentControllerAssembly
    ) {
        self.acquiringSdk = acquiringSdk
        self.paymentControllerAssembly = paymentControllerAssembly
    }

    // MARK: ISBPPaymentSheetAssembly

    func build(
        paymentFlow: PaymentFlow,
        amount: Int64,
        rebuilId: String,
        moduleCompletion: PaymentResultCompletion?
    ) -> UIViewController {
        let paymentController = paymentControllerAssembly.paymentController()

        let presenter = RecurrentPaymentPresenter(
            paymentController: paymentController,
            paymentFlow: paymentFlow,
            rebuilId: rebuilId,
            moduleCompletion: moduleCompletion
        )

        let view = RecurrentPaymentViewController(presenter: presenter)
        presenter.view = view

        paymentController.delegate = presenter

        let pullableContainerViewController = PullableContainerViewController(content: view)
        return pullableContainerViewController
    }
}
