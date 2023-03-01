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

    private let cardsControllerAssembly: ICardsControllerAssembly
    private let paymentControllerAssembly: IPaymentControllerAssembly
    private let cardListAssembly: ICardListAssembly

    // MARK: Initialization

    init(
        cardsControllerAssembly: ICardsControllerAssembly,
        paymentControllerAssembly: IPaymentControllerAssembly,
        cardListAssembly: ICardListAssembly
    ) {
        self.cardsControllerAssembly = cardsControllerAssembly
        self.paymentControllerAssembly = paymentControllerAssembly
        self.cardListAssembly = cardListAssembly
    }

    // MARK: ICardPaymentAssembly

    func anyCardPayment(
        activeCards: [PaymentCard]?,
        paymentFlow: PaymentFlow,
        amount: Int64,
        output: ICardPaymentPresenterModuleOutput?,
        cardListOutput: ICardListPresenterOutput?
    ) -> UIViewController {
        let paymentController = paymentControllerAssembly.paymentController()
        let cardsController = (paymentFlow.customerOptions?.customerKey).map { cardsControllerAssembly.cardsController(customerKey: $0) }

        let router = CardPaymentRouter(cardListAssembly: cardListAssembly)

        let presenter = CardPaymentPresenter(
            router: router,
            output: output,
            cardListOutput: cardListOutput,
            cardsController: cardsController,
            paymentController: paymentController,
            activeCards: activeCards,
            paymentFlow: paymentFlow,
            amount: amount
        )

        let view = CardPaymentViewController(presenter: presenter)
        presenter.view = view
        router.transitionHandler = view

        paymentController.delegate = presenter
        paymentController.webFlowDelegate = view

        return view
    }
}
