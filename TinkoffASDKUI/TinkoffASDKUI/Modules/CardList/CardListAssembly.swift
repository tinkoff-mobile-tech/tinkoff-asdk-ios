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

/// Объект, осуществляющий сборку модуля `CardList` для различных пользовательских сценариев
protocol ICardListAssembly {
    /// Отображение списка карт в качестве самостоятельного экрана
    ///
    /// Доступные операции: добавление, удаление
    func cardsPresentingModule(customerKey: String) -> (view: CardListViewController, module: ICardListModule)

    /// Отображение списка карт, вызываемого с платежной формы
    ///
    /// Доступные операции: добавление, удаление, выбор карты
    func cardSelectionModule(
        customerKey: String,
        selectedCardId: String,
        cards: [PaymentCard]
    ) -> (view: CardListViewController, module: ICardListModule)
}

final class CardListAssembly: ICardListAssembly {
    // MARK: Dependencies

    private let cardsControllerAssembly: ICardsControllerAssembly
    private let addNewCardAssembly: IAddNewCardAssembly

    // MARK: Init

    init(
        cardsControllerAssembly: ICardsControllerAssembly,
        addNewCardAssembly: IAddNewCardAssembly
    ) {
        self.cardsControllerAssembly = cardsControllerAssembly
        self.addNewCardAssembly = addNewCardAssembly
    }

    // MARK: ICardListAssembly

    func cardsPresentingModule(
        customerKey: String
    ) -> (view: CardListViewController, module: ICardListModule) {
        buildModule(
            customerKey: customerKey,
            configuration: .cardList()
        )
    }

    func cardSelectionModule(
        customerKey: String,
        selectedCardId: String,
        cards: [PaymentCard]
    ) -> (view: CardListViewController, module: ICardListModule) {
        buildModule(
            customerKey: customerKey,
            configuration: .choosePaymentCardList(selectedCardId: selectedCardId)
        )
    }

    // MARK: Building

    private func buildModule(
        customerKey: String,
        configuration: CardListScreenConfiguration,
        cards: [PaymentCard] = []
    ) -> (view: CardListViewController, module: ICardListModule) {

        let router = CardListRouter(addNewCardAssembly: addNewCardAssembly)

        let presenter = CardListPresenter(
            screenConfiguration: configuration,
            cardsController: cardsControllerAssembly.cardsController(customerKey: customerKey),
            router: router,
            imageResolver: PaymentSystemImageResolver(),
            bankResolver: BankResolver(),
            paymentSystemResolver: PaymentSystemResolver(),
            cards: cards
        )

        let view = CardListViewController(
            configuration: configuration,
            presenter: presenter
        )

        router.transitionHandler = view
        presenter.view = view

        return (view, presenter)
    }
}

// MARK: - CardListScreenConfiguration + Styles

private extension CardListScreenConfiguration {
    static func cardList() -> Self {
        Self(
            listItemsAreSelectable: false,
            navigationTitle: Loc.Acquiring.CardList.screenTitle,
            addNewCardCellTitle: Loc.Acquiring.CardList.addCard,
            selectedCardId: nil
        )
    }

    static func choosePaymentCardList(selectedCardId: String) -> Self {
        // заменить строки на ключи после добавления на странице локализации в спеке
        Self(
            listItemsAreSelectable: true,
            navigationTitle: Loc.CardList.Screen.Title.paymentByCard,
            addNewCardCellTitle: Loc.CardList.Button.anotherCard,
            selectedCardId: selectedCardId
        )
    }
}
