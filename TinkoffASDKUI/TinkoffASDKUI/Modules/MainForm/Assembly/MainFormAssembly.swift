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
    private let cardsControllerAssembly: ICardsControllerAssembly
    private let tinkoffPayAssembly: ITinkoffPayAssembly
    private let cardListAssembly: ICardListAssembly
    private let cardPaymentAssembly: ICardPaymentAssembly
    private let sbpBanksAssembly: ISBPBanksAssembly

    // MARK: Initialization

    init(
        coreSDK: AcquiringSdk,
        paymentControllerAssembly: IPaymentControllerAssembly,
        cardsControllerAssembly: ICardsControllerAssembly,
        tinkoffPayAssembly: ITinkoffPayAssembly,
        cardListAssembly: ICardListAssembly,
        cardPaymentAssembly: ICardPaymentAssembly,
        sbpBanksAssembly: ISBPBanksAssembly
    ) {
        self.coreSDK = coreSDK
        self.paymentControllerAssembly = paymentControllerAssembly
        self.cardsControllerAssembly = cardsControllerAssembly
        self.tinkoffPayAssembly = tinkoffPayAssembly
        self.cardListAssembly = cardListAssembly
        self.cardPaymentAssembly = cardPaymentAssembly
        self.sbpBanksAssembly = sbpBanksAssembly
    }

    // MARK: IMainFormAssembly

    func build(
        paymentFlow: PaymentFlow,
        configuration: MainFormUIConfiguration,
        moduleCompletion: PaymentResultCompletion?
    ) -> UIViewController {
        let paymentController = paymentControllerAssembly.paymentController()
        let cardsController = paymentFlow.customerKey.map(cardsControllerAssembly.cardsController(customerKey:))

        let appChecker = AppChecker()

        let dataStateLoader = MainFormDataStateLoader(
            terminalService: coreSDK,
            cardsController: cardsController,
            sbpBanksService: SBPBanksService(acquiringSdk: coreSDK),
            sbpBankAppChecker: SBPBankAppChecker(appChecker: appChecker),
            tinkoffPayAppChecker: tinkoffPayAssembly.tinkoffPayAppChecker()
        )

        let tinkoffPayController = tinkoffPayAssembly.tinkoffPayController()

        let router = MainFormRouter(
            configuration: configuration,
            cardListAssembly: cardListAssembly,
            cardPaymentAssembly: cardPaymentAssembly,
            sbpBanksAssembly: sbpBanksAssembly
        )

        let presenter = MainFormPresenter(
            router: router,
            dataStateLoader: dataStateLoader,
            paymentController: paymentController,
            tinkoffPayController: tinkoffPayController,
            paymentFlow: paymentFlow,
            configuration: configuration,
            moduleCompletion: moduleCompletion
        )

        let view = MainFormViewController(presenter: presenter)

        router.transitionHandler = view
        presenter.view = view

        paymentController.delegate = presenter
        paymentController.webFlowDelegate = view
        tinkoffPayController.delegate = presenter

        let pullableContainerViewController = PullableContainerViewController(content: view)
        return pullableContainerViewController
    }
}
