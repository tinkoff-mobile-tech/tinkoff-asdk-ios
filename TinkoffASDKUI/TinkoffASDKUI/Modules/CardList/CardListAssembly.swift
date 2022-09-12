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


import UIKit
import TinkoffASDKCore

/// Объект, осуществляющий сборку модуля `CardList` для различных пользовательских сценариев
protocol ICardListAssembly {
    /// Отображение списка карт в качестве самостоятельного экрана
    ///
    /// Доступные операции: добавление, удаление
    func cardsPresentingModule(
        cardListProvider: CardListDataProvider,
        configuration: AcquiringViewConfiguration
    ) -> (view: UIViewController, module: ICardListModule)

    /// Отображение списка карт, вызываемого с платежной формы
    ///
    /// Доступные операции: добавление, удаление, выбор карты
    func cardSelectionModule(
        cardListProvider: CardListDataProvider,
        configuration: AcquiringViewConfiguration
    ) -> (view: UIViewController, module: ICardListModule)
}

final class CardListAssembly: ICardListAssembly {
    private let primaryButtonStyle: ButtonStyle?

    init(primaryButtonStyle: ButtonStyle?) {
        self.primaryButtonStyle = primaryButtonStyle
    }

    // MARK: ICardListAssembly

    func cardsPresentingModule(
        cardListProvider: CardListDataProvider,
        configuration: AcquiringViewConfiguration
    ) -> (view: UIViewController, module: ICardListModule) {
        buildModule(
            provider: PaymentCardsProvider(dataProvider: cardListProvider, fetchingStrategy: .backendOnly),
            style: .presenting(primaryButtonStyle: primaryButtonStyle),
            configuration: configuration
        )
    }

    func cardSelectionModule(
        cardListProvider: CardListDataProvider,
        configuration: AcquiringViewConfiguration
    ) -> (view: UIViewController, module: ICardListModule) {
        buildModule(
            provider: PaymentCardsProvider(dataProvider: cardListProvider, fetchingStrategy: .cacheOnly),
            style: .selection(primaryButtonStyle: primaryButtonStyle),
            configuration: configuration
        )
    }

    // MARK: Building

    private func buildModule(
        provider: IPaymentCardsProvider,
        style: CardListView.Style,
        configuration: AcquiringViewConfiguration
    ) -> (view: UIViewController, module: ICardListModule) {
        let presenter = CardListPresenter(
            imageResolver: PaymentSystemImageResolver(),
            provider: provider
        )

        let view = CardListViewController(
            style: style,
            presenter: presenter,
            externalAlertsFactory: configuration.alertViewHelper
        )

        presenter.view = view
        return (view, presenter)
    }
}

// MARK: - CardListViewController + Styles

private extension CardListView.Style {
    static func presenting(primaryButtonStyle: ButtonStyle?) -> CardListView.Style {
        CardListView.Style(
            listItemsAreSelectable: false,
            primaryButtonStyle: primaryButtonStyle,
            backgroundColor: .asdk.dynamic.background.elevation1
        )
    }

    static func selection(primaryButtonStyle: ButtonStyle?) -> CardListView.Style {
        CardListView.Style(
            listItemsAreSelectable: true,
            primaryButtonStyle: primaryButtonStyle,
            backgroundColor: .asdk.dynamic.background.elevation1
        )
    }
}
