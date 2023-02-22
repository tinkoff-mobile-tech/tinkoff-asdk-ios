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

    private let paymentFlow: PaymentFlow

    // MARK: Init

    init(
        configuration: MainFormUIConfiguration,
        cardListAssembly: ICardListAssembly,
        cardPaymentAssembly: ICardPaymentAssembly,
        sbpBanksAssembly: ISBPBanksAssembly,
        paymentFlow: PaymentFlow
    ) {
        self.configuration = configuration
        self.cardListAssembly = cardListAssembly
        self.cardPaymentAssembly = cardPaymentAssembly
        self.sbpBanksAssembly = sbpBanksAssembly
        self.paymentFlow = paymentFlow
    }

    // MARK: IMainFormRouter

    func openCardList(paymentFlow: PaymentFlow, cards: [PaymentCard], selectedCard: PaymentCard, output: ICardListPresenterOutput?) {
        guard let customerKey = paymentFlow.customerOptions?.customerKey else { return }

        let navigationController = cardListAssembly.cardSelectionNavigationController(
            customerKey: customerKey,
            cards: cards,
            selectedCard: selectedCard,
            paymentFlow: paymentFlow,
            output: output
        )

        transitionHandler?.present(navigationController, animated: true)
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
