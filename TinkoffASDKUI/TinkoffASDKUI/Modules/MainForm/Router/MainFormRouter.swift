//
//  MainFormRouter.swift
//  TinkoffASDKUI
//
//  Created by r.akhmadeev on 19.01.2023.
//

import TinkoffASDKCore
import UIKit

final class MainFormRouter: IMainFormRouter {
    // MARK: Dependencies

    weak var transitionHandler: UIViewController?
    private let configuration: MainFormUIConfiguration
    private let cardListAssembly: ICardListAssembly
    private let cardPaymentAssembly: ICardPaymentAssembly
    private let sbpBanksAssembly: ISBPBanksAssembly

    // MARK: State

    private weak var cardSelectionNavigationController: UINavigationController?

    // MARK: Init

    init(
        configuration: MainFormUIConfiguration,
        cardListAssembly: ICardListAssembly,
        cardPaymentAssembly: ICardPaymentAssembly,
        sbpBanksAssembly: ISBPBanksAssembly
    ) {
        self.configuration = configuration
        self.cardListAssembly = cardListAssembly
        self.cardPaymentAssembly = cardPaymentAssembly
        self.sbpBanksAssembly = sbpBanksAssembly
    }

    // MARK: IMainFormRouter

    func openCardSelection(paymentFlow: PaymentFlow, cards: [PaymentCard], selectedCard: PaymentCard, output: ICardListPresenterOutput?) {
        guard let customerKey = paymentFlow.customerOptions?.customerKey else { return }

        let cardSelectionNavigationController = cardListAssembly.cardSelectionNavigationController(
            customerKey: customerKey,
            cards: cards,
            selectedCard: selectedCard,
            paymentFlow: paymentFlow,
            output: output
        )

        self.cardSelectionNavigationController = cardSelectionNavigationController

        transitionHandler?.present(cardSelectionNavigationController, animated: true)
    }

    func pushNewCardPaymentToCardSelection(paymentFlow: PaymentFlow, output: ICardPaymentPresenterModuleOutput?) {
        let cardPaymentViewController = cardPaymentAssembly.build(
            activeCards: [],
            paymentFlow: paymentFlow,
            amount: configuration.amount,
            output: output
        )

        cardSelectionNavigationController?.pushViewController(cardPaymentViewController, animated: true)
    }

    func closeCardSelection(completion: VoidBlock?) {
        guard let cardSelectionNavigationController = cardSelectionNavigationController else {
            completion?()
            return
        }

        cardSelectionNavigationController.dismiss(animated: true, completion: completion)
    }

    func openCardPayment(paymentFlow: PaymentFlow, cards: [PaymentCard]?, output: ICardPaymentPresenterModuleOutput?) {
        let cardPaymentViewController = cardPaymentAssembly.build(
            activeCards: cards,
            paymentFlow: paymentFlow,
            amount: configuration.amount,
            output: output
        )

        let navVC = UINavigationController.withASDKBar(rootViewController: cardPaymentViewController)
        transitionHandler?.present(navVC, animated: true)
    }

    func openTinkoffPay(paymentFlow: PaymentFlow) {}

    func openSBP(paymentFlow: PaymentFlow, paymentSheetOutput: ISBPPaymentSheetPresenterOutput?) {
        let sbpModule = sbpBanksAssembly.buildInitialModule(
            paymentFlow: paymentFlow,
            paymentSheetOutput: paymentSheetOutput
        )

        let navVC = UINavigationController.withASDKBar(rootViewController: sbpModule.view)
        transitionHandler?.present(navVC, animated: true)
    }
}
