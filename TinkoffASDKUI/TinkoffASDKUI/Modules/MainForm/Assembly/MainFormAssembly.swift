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
    private let tinkoffPayLandingAssembly: ITinkoffPayLandingAssembly
    private let cardListAssembly: ICardListAssembly
    private let cardPaymentAssembly: ICardPaymentAssembly
    private let sbpBanksAssembly: ISBPBanksAssembly

    // MARK: Initialization

    init(
        coreSDK: AcquiringSdk,
        paymentControllerAssembly: IPaymentControllerAssembly,
        cardsControllerAssembly: ICardsControllerAssembly,
        tinkoffPayAssembly: ITinkoffPayAssembly,
        tinkoffPayLandingAssembly: ITinkoffPayLandingAssembly,
        cardListAssembly: ICardListAssembly,
        cardPaymentAssembly: ICardPaymentAssembly,
        sbpBanksAssembly: ISBPBanksAssembly
    ) {
        self.coreSDK = coreSDK
        self.paymentControllerAssembly = paymentControllerAssembly
        self.cardsControllerAssembly = cardsControllerAssembly
        self.tinkoffPayAssembly = tinkoffPayAssembly
        self.tinkoffPayLandingAssembly = tinkoffPayLandingAssembly
        self.cardListAssembly = cardListAssembly
        self.cardPaymentAssembly = cardPaymentAssembly
        self.sbpBanksAssembly = sbpBanksAssembly
    }

    // MARK: IMainFormAssembly

    func build(
        paymentFlow: PaymentFlow,
        configuration: MainFormUIConfiguration,
        cardScannerDelegate: ICardScannerDelegate?,
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
            cardListAssembly: cardListAssembly,
            cardPaymentAssembly: cardPaymentAssembly,
            sbpBanksAssembly: sbpBanksAssembly,
            tinkoffPayLandingAssembly: tinkoffPayLandingAssembly
        )

        let presenter = MainFormPresenter(
            router: router,
            dataStateLoader: dataStateLoader,
            paymentController: paymentController,
            tinkoffPayController: tinkoffPayController,
            paymentFlow: paymentFlow,
            configuration: configuration,
            cardScannerDelegate: cardScannerDelegate,
            moduleCompletion: moduleCompletion
        )

        let tableContentProvider = MainFormTableContentProvider()

        let view = MainFormViewController(presenter: presenter, tableContentProvider: tableContentProvider)

        router.transitionHandler = view
        presenter.view = view

        paymentController.delegate = presenter
        paymentController.webFlowDelegate = view
        tinkoffPayController.delegate = presenter

        let pullableContainerViewController = PullableContainerViewController(content: view)
        view.pullableContentDelegate = pullableContainerViewController

        return pullableContainerViewController
    }
}
