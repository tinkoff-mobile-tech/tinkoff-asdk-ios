//
//  CardListRouter.swift
//  TinkoffASDKUI
//
//  Created by r.akhmadeev on 22.02.2023.
//

import UIKit

final class CardListRouter: ICardListRouter {
    // MARK: Dependencies

    weak var transitionHandler: UIViewController?
    private let addNewCardAssembly: IAddNewCardAssembly
    private let cardPaymentAssembly: ICardPaymentAssembly

    // MARK: CardPayment Flow Dependencies

    private let paymentFlow: PaymentFlow?
    private let amount: Int64?
    private weak var cardPaymentOutput: ICardPaymentPresenterModuleOutput?
    private weak var cardScannerDelegate: ICardScannerDelegate?

    // MARK: Init

    init(
        addNewCardAssembly: IAddNewCardAssembly,
        cardPaymentAssembly: ICardPaymentAssembly,
        paymentFlow: PaymentFlow?,
        amount: Int64?,
        cardPaymentOutput: ICardPaymentPresenterModuleOutput?,
        cardScannerDelegate: ICardScannerDelegate?
    ) {
        self.addNewCardAssembly = addNewCardAssembly
        self.cardPaymentAssembly = cardPaymentAssembly
        self.paymentFlow = paymentFlow
        self.amount = amount
        self.cardPaymentOutput = cardPaymentOutput
        self.cardScannerDelegate = cardScannerDelegate
    }

    // MARK: ICardListRouter

    func openAddNewCard(customerKey: String, output: IAddNewCardPresenterOutput?) {
        let viewController = addNewCardAssembly.addNewCardView(
            customerKey: customerKey,
            output: output,
            cardScannerDelegate: cardScannerDelegate
        )
        transitionHandler?.navigationController?.pushViewController(viewController, animated: true)
    }

    func openCardPayment() {
        guard let paymentFlow = paymentFlow, let amount = amount else { return }

        let viewController = cardPaymentAssembly.newCardPayment(
            paymentFlow: paymentFlow,
            amount: amount,
            output: cardPaymentOutput,
            cardScannerDelegate: cardScannerDelegate
        )

        transitionHandler?.navigationController?.pushViewController(viewController, animated: true)
    }
}
