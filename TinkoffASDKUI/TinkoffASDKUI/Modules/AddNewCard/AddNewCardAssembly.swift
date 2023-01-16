//
//  AddNewCardAssembly.swift
//  TinkoffASDKUI
//
//  Created by Ivan Glushko on 20.12.2022.
//

import Foundation

protocol IAddNewCardAssembly {

    func assemble(
        addNewCardOutput: IAddNewCardOutput?,
        networking: IAddNewCardNetworking
    ) -> AddNewCardViewController
}

final class AddNewCardAssembly: IAddNewCardAssembly {

    func assemble(
        addNewCardOutput: IAddNewCardOutput?,
        networking: IAddNewCardNetworking
    ) -> AddNewCardViewController {

        let presenter = AddNewCardPresenter(networking: networking, output: addNewCardOutput)
        let viewController = AddNewCardViewController(
            presenter: presenter,
            cardFieldFactory: CardFieldFactory()
        )
        presenter.view = viewController
        return viewController
    }
}
