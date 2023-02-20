//
//  AddNewCardAssembly.swift
//  TinkoffASDKUI
//
//  Created by Ivan Glushko on 20.12.2022.
//

import Foundation
import UIKit

protocol IAddNewCardAssembly {
    func assemble(customerKey: String, output: IAddNewCardOutput?) -> AddNewCardViewController
}

final class AddNewCardAssembly: IAddNewCardAssembly {
    // MARK: Dependencies

    private let cardsControllerAssembly: ICardsControllerAssembly

    // MARK: Init

    init(cardsControllerAssembly: ICardsControllerAssembly) {
        self.cardsControllerAssembly = cardsControllerAssembly
    }

    // MARK: IAddNewCardAssembly

    func assemble(customerKey: String, output: IAddNewCardOutput?) -> AddNewCardViewController {
        let cardsController = cardsControllerAssembly.cardsController(customerKey: customerKey)

        let presenter = AddNewCardPresenter(
            cardsController: cardsController,
            output: output
        )

        let viewController = AddNewCardViewController(presenter: presenter)
        presenter.view = viewController
        cardsController.webFlowDelegate = viewController

        return viewController
    }
}
