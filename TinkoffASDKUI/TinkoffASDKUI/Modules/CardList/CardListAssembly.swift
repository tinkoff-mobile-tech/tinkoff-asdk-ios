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
    /// Создает экран со списком карт, обернутый в `UINavigationController`
    ///
    /// Используется для отображения списка карт в сценарии управления картами, доступного при открытии из родительского приложения
    /// - Parameter customerKey: Идентификатор покупателя в системе Продавца
    /// - Returns: `UINavigationController`
    func cardsPresentingNavigationController(customerKey: String) -> UINavigationController
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

    func cardsPresentingNavigationController(customerKey: String) -> UINavigationController {
        let view = createModule(customerKey: customerKey, configuration: .cardList())
        let navigationController = UINavigationController(rootViewController: view)

        if #available(iOS 13.0, *) {
            // Fixes flickering of nav bar when using pushing transitioning animation
            let navBarAppearance = UINavigationBarAppearance()
            navBarAppearance.configureWithTransparentBackground()
            navBarAppearance.backgroundColor = ASDKColors.Background.elevation1.color
            navigationController.navigationBar.standardAppearance = navBarAppearance
            navigationController.navigationBar.scrollEdgeAppearance = navBarAppearance
            navigationController.navigationBar.compactAppearance = navBarAppearance
        }

        return navigationController
    }

    // MARK: Building

    private func createModule(
        customerKey: String,
        configuration: CardListScreenConfiguration,
        cards: [PaymentCard] = []
    ) -> UIViewController {
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

        view.extendedLayoutIncludesOpaqueBars = true

        router.transitionHandler = view
        presenter.view = view

        return view
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
