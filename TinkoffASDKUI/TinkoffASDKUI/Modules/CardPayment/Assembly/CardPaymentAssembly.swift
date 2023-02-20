//
//  CardPaymentAssembly.swift
//  TinkoffASDKUI
//
//  Created by Aleksandr Pravosudov on 20.01.2023.
//

import TinkoffASDKCore
import UIKit

final class CardPaymentAssembly: ICardPaymentAssembly {

    // MARK: Dependencies

    private let coreSDK: AcquiringSdk
    private let paymentControllerAssembly: IPaymentControllerAssembly

    // MARK: Initialization

    init(
        coreSDK: AcquiringSdk,
        paymentControllerAssembly: IPaymentControllerAssembly
    ) {
        self.coreSDK = coreSDK
        self.paymentControllerAssembly = paymentControllerAssembly
    }

    // MARK: ICardPaymentAssembly

    func build(
        activeCards: [PaymentCard]?,
        paymentFlow: PaymentFlow,
        amount: Int64,
        output: ICardPaymentPresenterModuleOutput?
    ) -> UIViewController {
        let paymentController = paymentControllerAssembly.paymentController()

        let router = CardPaymentRouter()
        let presenter = CardPaymentPresenter(
            router: router,
            output: output,
            coreSDK: coreSDK,
            paymentController: paymentController,
            activeCards: activeCards,
            paymentFlow: paymentFlow,
            amount: Int(amount)
        )

        let view = CardPaymentViewController(presenter: presenter)
        presenter.view = view
        router.transitionHandler = view

        paymentController.delegate = presenter
        paymentController.webFlowDelegate = view

        return view
    }
}
