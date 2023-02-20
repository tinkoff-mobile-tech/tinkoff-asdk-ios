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

    init(cardsControllerAssembly: ICardsControllerAssembly) {
        self.cardsControllerAssembly = cardsControllerAssembly
    }

    func assemble(customerKey: String, output: IAddNewCardOutput?) -> AddNewCardViewController {
        let presenter = AddNewCardPresenter(
            cardsController: cardsControllerAssembly.cardsController(customerKey: customerKey),
            output: output
        )

        let viewController = AddNewCardViewController(presenter: presenter)
        presenter.view = viewController
        return viewController
    }
}
