//
//  CardPaymentRouter.swift
//  TinkoffASDKUI
//
//  Created by Aleksandr Pravosudov on 20.01.2023.
//

import TinkoffASDKCore
import UIKit

final class CardPaymentRouter: ICardPaymentRouter {

    // MARK: Dependencies

    weak var transitionHandler: UIViewController?

    private let cardListAssembly: ICardListAssembly
    private weak var cardScannerDelegate: ICardScannerDelegate?

    // MARK: Initialization

    init(
        cardListAssembly: ICardListAssembly,
        cardScannerDelegate: ICardScannerDelegate?
    ) {
        self.cardListAssembly = cardListAssembly
        self.cardScannerDelegate = cardScannerDelegate
    }
}

// MARK: - ICardPaymentRouter

extension CardPaymentRouter {
    func closeScreen(completion: VoidBlock?) {
        transitionHandler?.dismiss(animated: true, completion: completion)
    }

    func showCardScanner(completion: @escaping CardScannerCompletion) {
        guard let transitionHandler = transitionHandler else { return }
        cardScannerDelegate?.cardScanButtonDidPressed(on: transitionHandler, completion: completion)
    }

    func openCardPaymentList(
        paymentFlow: PaymentFlow,
        amount: Int64,
        cards: [PaymentCard],
        selectedCard: PaymentCard,
        cardListOutput: ICardListPresenterOutput?,
        cardPaymentOutput: ICardPaymentPresenterModuleOutput?
    ) {
        guard let customerKey = paymentFlow.customerKey else { return }

        let cardPaymentList = cardListAssembly.cardPaymentList(
            customerKey: customerKey,
            cards: cards,
            selectedCard: selectedCard,
            paymentFlow: paymentFlow,
            amount: amount,
            output: cardListOutput,
            cardPaymentOutput: cardPaymentOutput,
            cardScannerDelegate: cardScannerDelegate
        )

        transitionHandler?.navigationController?.pushViewController(cardPaymentList, animated: true)
    }
}
