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
        cardListOutput: ICardListPresenterOutput?,
        cardScannerDelegate: ICardScannerDelegate?
    ) -> UIViewController {
        let paymentController = paymentControllerAssembly.paymentController()
        let cardsController = (paymentFlow.customerOptions?.customerKey).map {
            cardsControllerAssembly.cardsController(
                customerKey: $0,
                addCardOptions: .empty
            )
        }

        let validator = CardRequisitesValidator()
        let paymentSystemResolver = PaymentSystemResolver()
        let bankResolver = BankResolver()

        let savedCardViewPresenterAssembly = SavedCardViewPresenterAssembly(
            validator: validator,
            paymentSystemResolver: paymentSystemResolver,
            bankResolver: bankResolver
        )

        let inputMaskResolver = CardRequisitesMasksResolver(paymentSystemResolver: paymentSystemResolver)

        let cardFieldPresenterAssembly = CardFieldPresenterAssembly(
            validator: validator,
            paymentSystemResolver: paymentSystemResolver,
            bankResolver: bankResolver,
            inputMaskResolver: inputMaskResolver
        )

        let switchViewPresenterAssembly = SwitchViewPresenterAssembly()
        let emailViewPresenterAssembly = EmailViewPresenterAssembly()

        let moneyFormatter = MoneyFormatter()
        let payButtonViewPresenterAssembly = PayButtonViewPresenterAssembly(moneyFormatter: moneyFormatter)

        let router = CardPaymentRouter(
            cardListAssembly: cardListAssembly,
            cardScannerDelegate: cardScannerDelegate
        )

        let presenter = CardPaymentPresenter(
            router: router,
            output: output,
            savedCardViewPresenterAssembly: savedCardViewPresenterAssembly,
            cardFieldPresenterAssembly: cardFieldPresenterAssembly,
            switchViewPresenterAssembly: switchViewPresenterAssembly,
            emailViewPresenterAssembly: emailViewPresenterAssembly,
            payButtonViewPresenterAssembly: payButtonViewPresenterAssembly,
            cardListOutput: cardListOutput,
            cardsController: cardsController,
            paymentController: paymentController,
            mainDispatchQueue: DispatchQueue.main,
            activeCards: activeCards,
            paymentFlow: paymentFlow,
            amount: amount,
            isCardFieldScanButtonNeeded: cardScannerDelegate != nil
        )

        let view = CardPaymentViewController(presenter: presenter)
        presenter.view = view
        router.transitionHandler = view

        paymentController.delegate = presenter
        paymentController.webFlowDelegate = view

        return view
    }
}
