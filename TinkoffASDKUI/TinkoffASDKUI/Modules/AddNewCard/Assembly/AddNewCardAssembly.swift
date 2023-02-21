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

    func addNewCardView(customerKey: String, output: IAddNewCardPresenterOutput?) -> AddNewCardViewController {
        createModule(customerKey: customerKey, output: output, onViewWasClosed: nil)
    }

    func addNewCardNavigationController(
        customerKey: String,
        onViewWasClosed: ((AddCardResult) -> Void)?
    ) -> UINavigationController {
        let viewController = createModule(customerKey: customerKey, output: nil, onViewWasClosed: onViewWasClosed)
        let navigationController = UINavigationController(rootViewController: viewController)
        return navigationController
    }

    // MARK: Helpers

    private func createModule(
        customerKey: String,
        output: IAddNewCardPresenterOutput?,
        onViewWasClosed: ((AddCardResult) -> Void)?
    ) -> AddNewCardViewController {
        let cardsController = cardsControllerAssembly.cardsController(customerKey: customerKey)

        let presenter = AddNewCardPresenter(
            cardsController: cardsController,
            output: output,
            onViewWasClosed: onViewWasClosed
        )

        let viewController = AddNewCardViewController(presenter: presenter)
        presenter.view = viewController
        cardsController.webFlowDelegate = viewController

        return viewController
    }
}
