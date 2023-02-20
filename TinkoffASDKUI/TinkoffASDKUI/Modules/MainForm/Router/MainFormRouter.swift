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
    private let cardPaymentAssembly: ICardPaymentAssembly

    // MARK: Init

    init(
        configuration: MainFormUIConfiguration,
        cardPaymentAssembly: ICardPaymentAssembly
    ) {
        self.configuration = configuration
        self.cardPaymentAssembly = cardPaymentAssembly
    }

    // MARK: IMainFormRouter

    func openCardPayment(paymentFlow: PaymentFlow, cards: [PaymentCard]?, output: ICardPaymentPresenterModuleOutput?) {
        let cardPaymentViewController = cardPaymentAssembly.build(
            activeCards: cards,
            paymentFlow: paymentFlow,
            amount: configuration.amount,
            output: output
        )

        let navVC = UINavigationController(rootViewController: cardPaymentViewController)
        transitionHandler?.present(navVC, animated: true)
    }

    func openSBP(paymentFlow: PaymentFlow) {}

    func openTinkoffPay(paymentFlow: PaymentFlow) {}
}
