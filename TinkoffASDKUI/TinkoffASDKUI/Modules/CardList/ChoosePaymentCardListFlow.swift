//
//  ChoosePaymentCardListFlow.swift
//  TinkoffASDKUI
//
//  Created by Ivan Glushko on 30.12.2022.
//

import TinkoffASDKCore
import UIKit

// MARK: - ICardListFlow

protocol IChoosePaymentCardListFlow {
    func start(context: ChoosePaymentCardListContext)
}

final class ChoosePaymentCardListContext {
    let baseContext: CardListContext
    var selectedCardId: String
    let setOutputEvents: (ICardListModule) -> Void

    init(
        baseContext: CardListContext,
        selectedCardId: String,
        setOutputEvents: @escaping (ICardListModule) -> Void
    ) {
        self.baseContext = baseContext
        self.setOutputEvents = setOutputEvents
        self.selectedCardId = selectedCardId
    }
}

final class ChoosePaymentCardListFlow {

    private let cardListAssembly: ICardListAssembly
    private let cardListDataProvider: CardListDataProvider

    init(
        cardListAssembly: ICardListAssembly,
        cardListDataProvider: CardListDataProvider
    ) {
        self.cardListAssembly = cardListAssembly
        self.cardListDataProvider = cardListDataProvider
    }
}

extension ChoosePaymentCardListFlow: IChoosePaymentCardListFlow {

    func start(context: ChoosePaymentCardListContext) {
        let (cardListViewController, module) = cardListAssembly.cardSelectionModule(
            cardListProvider: cardListDataProvider,
            selectedCardId: context.selectedCardId
        )
        context.setOutputEvents(module)
        let navigationController = UINavigationController(rootViewController: cardListViewController)
        cardListViewController.extendedLayoutIncludesOpaqueBars = true
        context.baseContext.presentingViewController.present(navigationController, animated: true)
    }
}
