//
//  AddNewCardAssembly.swift
//  TinkoffASDKUI
//
//  Created by Ivan Glushko on 20.12.2022.
//

import Foundation
import UIKit

final class AddNewCardAssembly: IAddNewCardAssembly {
    // MARK: Dependencies

    private let cardsControllerAssembly: ICardsControllerAssembly

    // MARK: Init

    init(cardsControllerAssembly: ICardsControllerAssembly) {
        self.cardsControllerAssembly = cardsControllerAssembly
    }

    // MARK: IAddNewCardAssembly

    func addNewCardView(
        customerKey: String,
        output: IAddNewCardPresenterOutput?,
        cardScannerDelegate: ICardScannerDelegate?
    ) -> AddNewCardViewController {
        createModule(
            customerKey: customerKey,
            output: output,
            cardScannerDelegate: cardScannerDelegate,
            onViewWasClosed: nil
        )
    }

    func addNewCardNavigationController(
        customerKey: String,
        cardScannerDelegate: ICardScannerDelegate?,
        onViewWasClosed: ((AddCardResult) -> Void)?
    ) -> UINavigationController {
        let viewController = createModule(
            customerKey: customerKey,
            output: nil,
            cardScannerDelegate: cardScannerDelegate,
            onViewWasClosed: onViewWasClosed
        )
        return UINavigationController.withElevationBar(rootViewController: viewController)
    }

    // MARK: Helpers

    private func createModule(
        customerKey: String,
        output: IAddNewCardPresenterOutput?,
        cardScannerDelegate: ICardScannerDelegate?,
        onViewWasClosed: ((AddCardResult) -> Void)?
    ) -> AddNewCardViewController {
        let cardsController = cardsControllerAssembly.cardsController(customerKey: customerKey)

        let presenter = AddNewCardPresenter(
            cardsController: cardsController,
            output: output,
            isCardFieldScanButtonNeeded: cardScannerDelegate != nil,
            onViewWasClosed: onViewWasClosed
        )

        let view = AddNewCardViewController(presenter: presenter, cardScannerDelegate: cardScannerDelegate)

        presenter.view = view
        cardsController.webFlowDelegate = view

        return view
    }
}
