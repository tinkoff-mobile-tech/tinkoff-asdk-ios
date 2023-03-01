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

    func openCardPaymentList(
        paymentFlow: PaymentFlow,
        cards: [PaymentCard],
        selectedCard: PaymentCard,
        cardListOutput: ICardListPresenterOutput?,
        cardPaymentOutput: ICardPaymentPresenterModuleOutput?
    ) {
        guard let customerKey = paymentFlow.customerOptions?.customerKey else { return }

        let cardPaymentList = cardListAssembly.cardPaymentList(
            customerKey: customerKey,
            cards: cards,
            selectedCard: selectedCard,
            paymentFlow: paymentFlow,
            amount: configuration.amount,
            output: cardListOutput,
            cardPaymentOutput: cardPaymentOutput
        )

        let navigationController = UINavigationController.withASDKBar(rootViewController: cardPaymentList)

        transitionHandler?.present(navigationController, animated: true)
    }

    func openCardPayment(
        paymentFlow: PaymentFlow,
        cards: [PaymentCard]?,
        output: ICardPaymentPresenterModuleOutput?,
        cardListOutput: ICardListPresenterOutput?
    ) {
        let cardPaymentViewController = cardPaymentAssembly.anyCardPayment(
            activeCards: cards,
            paymentFlow: paymentFlow,
            amount: configuration.amount,
            output: output,
            cardListOutput: cardListOutput
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
