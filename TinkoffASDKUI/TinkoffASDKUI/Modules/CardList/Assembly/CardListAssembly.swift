//
//
//  CardListAssembly.swift
//
//  Copyright (c) 2021 Tinkoff Bank
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//   http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import TinkoffASDKCore
import UIKit

final class CardListAssembly: ICardListAssembly {
    // MARK: Dependencies

    private let paymentControllerAssembly: IPaymentControllerAssembly
    private let cardsControllerAssembly: ICardsControllerAssembly
    private let addNewCardAssembly: IAddNewCardAssembly

    // MARK: Init

    init(
        paymentControllerAssembly: IPaymentControllerAssembly,
        cardsControllerAssembly: ICardsControllerAssembly,
        addNewCardAssembly: IAddNewCardAssembly
    ) {
        self.paymentControllerAssembly = paymentControllerAssembly
        self.cardsControllerAssembly = cardsControllerAssembly
        self.addNewCardAssembly = addNewCardAssembly
    }

    // MARK: ICardListAssembly

    func cardsPresentingNavigationController(
        customerKey: String,
        cardScannerDelegate: ICardScannerDelegate?
    ) -> UINavigationController {
        let view = createModule(
            customerKey: customerKey,
            configuration: .cardList(),
            cardScannerDelegate: cardScannerDelegate
        )
        return UINavigationController.withElevationBar(rootViewController: view)
    }

    func cardPaymentList(
        customerKey: String,
        cards: [PaymentCard],
        selectedCard: PaymentCard,
        paymentFlow: PaymentFlow,
        amount: Int64,
        output: ICardListPresenterOutput?,
        cardPaymentOutput: ICardPaymentPresenterModuleOutput?,
        cardScannerDelegate: ICardScannerDelegate?
    ) -> UIViewController {
        createModule(
            customerKey: customerKey,
            configuration: .cardPaymentList(selectedCardId: selectedCard.cardId),
            cards: cards,
            paymentFlow: paymentFlow,
            amount: amount,
            output: output,
            cardPaymentOutput: cardPaymentOutput,
            cardScannerDelegate: cardScannerDelegate
        )
    }

    // MARK: Helpers

    private func createModule(
        customerKey: String,
        configuration: CardListScreenConfiguration,
        cards: [PaymentCard] = [],
        paymentFlow: PaymentFlow? = nil,
        amount: Int64? = nil,
        output: ICardListPresenterOutput? = nil,
        cardPaymentOutput: ICardPaymentPresenterModuleOutput? = nil,
        cardScannerDelegate: ICardScannerDelegate?
    ) -> UIViewController {
        // `CardPaymentAssembly` создается здесь, а не передается в кач-ве зависимости в `init`
        // из-за циклической связи зависимостей `CardPaymentAssembly` и `CardListAssembly`
        // Переход на навигацию через координаторы может исправить эту проблему
        // TODO: MIC-8101 Рассмотреть возможность и необходимость перехода на координаторы в навигации
        let cardPaymentAssembly = CardPaymentAssembly(
            cardsControllerAssembly: cardsControllerAssembly,
            paymentControllerAssembly: paymentControllerAssembly,
            cardListAssembly: self
        )

        let router = CardListRouter(
            addNewCardAssembly: addNewCardAssembly,
            cardPaymentAssembly: cardPaymentAssembly,
            paymentFlow: paymentFlow,
            amount: amount,
            cardPaymentOutput: cardPaymentOutput,
            cardScannerDelegate: cardScannerDelegate
        )

        let presenter = CardListPresenter(
            screenConfiguration: configuration,
            cardsController: cardsControllerAssembly.cardsController(customerKey: customerKey),
            router: router,
            imageResolver: PaymentSystemImageResolver(),
            bankResolver: BankResolver(),
            paymentSystemResolver: PaymentSystemResolver(),
            cards: cards,
            output: output
        )

        let view = CardListViewController(
            configuration: configuration,
            presenter: presenter
        )

        router.transitionHandler = view
        presenter.view = view

        return view
    }
}

// MARK: - CardListScreenConfiguration + Styles

private extension CardListScreenConfiguration {
    static func cardList() -> Self {
        Self(
            useCase: .cardList,
            selectedCardId: nil
        )
    }

    static func cardPaymentList(selectedCardId: String) -> Self {
        Self(
            useCase: .cardPaymentList,
            selectedCardId: selectedCardId
        )
    }
}
