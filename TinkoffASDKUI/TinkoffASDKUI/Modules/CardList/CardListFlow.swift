//
//  CardListFlow.swift
//  TinkoffASDKUI
//
//  Created by Ivan Glushko on 27.12.2022.
//

import TinkoffASDKCore
import UIKit

// MARK: - ICardListFlow

protocol ICardListFlow {
    func start(context: CardListContext)
}

struct CardListContext {
    let presentingViewController: UIViewController
    let customerKey: String
}

final class CardListFlow {

    private let cardListAssembly: ICardListAssembly
    private let cardListDataProvider: CardListDataProvider
    private let addCardAssembly: IAddNewCardAssembly
    private let addCardNetworking: IAddNewCardNetworking

    init(
        cardListAssembly: ICardListAssembly,
        cardListDataProvider: CardListDataProvider,
        addCardAssembly: IAddNewCardAssembly,
        addCardNetworking: IAddNewCardNetworking
    ) {
        self.cardListAssembly = cardListAssembly
        self.cardListDataProvider = cardListDataProvider
        self.addCardAssembly = addCardAssembly
        self.addCardNetworking = addCardNetworking
    }
}

extension CardListFlow: ICardListFlow {

    func start(context: CardListContext) {
        let (cardListViewController, module) = cardListAssembly.cardsPresentingModule(cardListProvider: cardListDataProvider)

        module.onAddNewCardTap = { [weak cardListViewController, addCardAssembly, addCardNetworking] in
            guard let cardListViewController = cardListViewController else { return }
            let addCardViewController = addCardAssembly.assemble(
                addNewCardOutput: cardListViewController.getAddNewCardOutput(),
                networking: addCardNetworking
            )

            addCardViewController.extendedLayoutIncludesOpaqueBars = true
            cardListViewController.navigationController?.pushViewController(
                addCardViewController,
                animated: true
            )
        }

        let navigationController = UINavigationController(rootViewController: cardListViewController)
        cardListViewController.extendedLayoutIncludesOpaqueBars = true
        handleAppearanceOf(navigationController: navigationController)
        context.presentingViewController.present(navigationController, animated: true)
    }

    private func handleAppearanceOf(navigationController: UINavigationController) {
        if #available(iOS 13.0, *) {
            // Fixes flickering of nav bar when using pushing transitioning animation
            let navBarAppearance = UINavigationBarAppearance()
            navBarAppearance.configureWithTransparentBackground()
            navBarAppearance.backgroundColor = ASDKColors.Background.elevation1.color
            navigationController.navigationBar.standardAppearance = navBarAppearance
            navigationController.navigationBar.scrollEdgeAppearance = navBarAppearance
            navigationController.navigationBar.compactAppearance = navBarAppearance
        }
    }
}
