//
//  MainFormAssembly.swift
//  TinkoffASDKUI
//
//  Created by r.akhmadeev on 19.01.2023.
//

import TinkoffASDKCore
import UIKit

final class MainFormAssembly: IMainFormAssembly {
    // MARK: Dependencies

    private let coreSDK: AcquiringSdk
    private let paymentControllerAssembly: IPaymentControllerAssembly
    private let cardPaymentAssembly: ICardPaymentAssembly

    // MARK: Initialization

    init(
        coreSDK: AcquiringSdk,
        paymentControllerAssembly: IPaymentControllerAssembly,
        cardPaymentAssembly: ICardPaymentAssembly
    ) {
        self.coreSDK = coreSDK
        self.paymentControllerAssembly = paymentControllerAssembly
        self.cardPaymentAssembly = cardPaymentAssembly
    }

    // MARK: IMainFormAssembly

    func build(
        paymentFlow: PaymentFlow,
        configuration: MainFormUIConfiguration,
        stub: MainFormStub
    ) -> UIViewController {
        let router = MainFormRouter(
            configuration: configuration,
            cardPaymentAssembly: cardPaymentAssembly
        )

        let presenter = MainFormPresenter(
            router: router,
            coreSDK: coreSDK,
            paymentFlow: paymentFlow,
            configuration: configuration,
            stub: stub
        )

        let viewController = MainFormViewController(presenter: presenter)

        router.transitionHandler = viewController
        presenter.view = viewController

        let pullableContainerViewController = PullableContainerViewController(content: viewController)
        return pullableContainerViewController
    }
}
