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

        let presenter = AddNewCardPresenter(
            cardFieldFactory: CardFieldFactory(),
            networking: networking
        )

        let viewController = AddNewCardViewController(
            output: addNewCardOutput,
            presenter: presenter
        )
        presenter.view = viewController
        return viewController
    }
}
