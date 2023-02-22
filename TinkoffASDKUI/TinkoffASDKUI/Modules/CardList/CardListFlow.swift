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
    func start(presentingViewController: UIViewController, customerKey: String)
}

final class CardListFlow {
    private let cardListAssembly: ICardListAssembly
    private let addCardAssembly: IAddNewCardAssembly

    init(
        cardListAssembly: ICardListAssembly,
        addCardAssembly: IAddNewCardAssembly
    ) {
        self.cardListAssembly = cardListAssembly
        self.addCardAssembly = addCardAssembly
    }
}

extension CardListFlow: ICardListFlow {
    func start(presentingViewController: UIViewController, customerKey: String) {
        let (cardListViewController, module) = cardListAssembly.cardsPresentingModule(customerKey: customerKey)

        module.onAddNewCardTap = { [weak cardListViewController, addCardAssembly] in
            guard let cardListViewController = cardListViewController else { return }

            let addCardViewController = addCardAssembly.addNewCardView(
                customerKey: customerKey,
                output: cardListViewController.getAddNewCardOutput()
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
        presentingViewController.present(navigationController, animated: true)
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
