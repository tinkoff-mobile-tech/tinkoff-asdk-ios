//
//  CardPaymentAssembly.swift
//  TinkoffASDKUI
//
//  Created by Aleksandr Pravosudov on 20.01.2023.
//

import TinkoffASDKCore
import UIKit

final class CardPaymentAssembly: ICardPaymentAssembly {

    // MARK: ICardPaymentAssembly

    func build(activeCards: [PaymentCard], paymentFlow: PaymentFlow, amount: Int64) -> UIViewController {
        let router = CardPaymentRouter()
        let moneyFormatter = MoneyFormatter()
        let presenter = CardPaymentPresenter(
            router: router,
            moneyFormatter: moneyFormatter,
            activeCards: activeCards,
            paymentFlow: paymentFlow,
            amount: Int(amount)
        )

        let view = CardPaymentViewController(presenter: presenter)
        presenter.view = view
        router.transitionHandler = view

        return view
    }
}
