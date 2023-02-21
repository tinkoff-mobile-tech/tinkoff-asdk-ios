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
    func start(
        presentingViewController: UIViewController,
        customerKey: String,
        selectedCardId: String,
        setOutputEvents: (ICardListModule) -> Void
    )
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
    func start(
        presentingViewController: UIViewController,
        customerKey: String,
        selectedCardId: String,
        setOutputEvents: (ICardListModule) -> Void
    ) {
        let (cardListViewController, module) = cardListAssembly.cardSelectionModule(
            cardListProvider: cardListDataProvider,
            selectedCardId: selectedCardId
        )

        setOutputEvents(module)
        let navigationController = UINavigationController(rootViewController: cardListViewController)
        cardListViewController.extendedLayoutIncludesOpaqueBars = true
        presentingViewController.present(navigationController, animated: true)
    }
}
