//
//  AddNewCardAssembly.swift
//  TinkoffASDKUI
//
//  Created by Ivan Glushko on 20.12.2022.
//

import Foundation
import UIKit

protocol IAddNewCardAssembly {
    func addNewCard(customerKey: String, output: IAddNewCardOutput?) -> AddNewCardViewController
    func addNewCard(customerKey: String, onViewWasClosed: ((AddCardResult) -> Void)?) -> AddNewCardViewController
}

final class AddNewCardAssembly: IAddNewCardAssembly {
    // MARK: Dependencies

    private let cardsControllerAssembly: ICardsControllerAssembly

    // MARK: Init

    init(cardsControllerAssembly: ICardsControllerAssembly) {
        self.cardsControllerAssembly = cardsControllerAssembly
    }

    // MARK: IAddNewCardAssembly

    func addNewCard(customerKey: String, output: IAddNewCardOutput?) -> AddNewCardViewController {
        createModule(customerKey: customerKey, output: output, onViewWasClosed: nil)
    }

    func addNewCard(customerKey: String, onViewWasClosed: ((AddCardResult) -> Void)?) -> AddNewCardViewController {
        createModule(customerKey: customerKey, output: nil, onViewWasClosed: onViewWasClosed)
    }

    // MARK: Helpers

    private func createModule(
        customerKey: String,
        output: IAddNewCardOutput?,
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
