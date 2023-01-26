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

    func build(activeCards: [PaymentCard], customerEmail: String) -> UIViewController {
        let router = CardPaymentRouter()
        let presenter = CardPaymentPresenter(
            router: router,
            activeCards: activeCards,
            customerEmail: customerEmail
        )

        let cardFieldFactory = CardFieldFactory()

        let view = CardPaymentViewController(
            presenter: presenter,
            cardFieldFactory: cardFieldFactory
        )
        presenter.view = view
        router.transitionHandler = view

        return view
    }
}
