//
//  AddCardListFlow.swift
//  TinkoffASDKUI
//
//  Created by Ivan Glushko on 27.12.2022.
//

import TinkoffASDKCore
import UIKit

protocol IAddCardFlow {
    func start(
        presentingViewController: UIViewController,
        customerKey: String,
        output: IAddNewCardOutput?
    )
}

final class AddCardListFlow {

    // Dependencies
    private let assembly: IAddNewCardAssembly

    init(assembly: IAddNewCardAssembly) {
        self.assembly = assembly
    }
}

extension AddCardListFlow: IAddCardFlow {
    func start(
        presentingViewController: UIViewController,
        customerKey: String,
        output: IAddNewCardOutput?
    ) {
        let addCardViewController = assembly.assemble(customerKey: customerKey, output: output)
        let navigationController = UINavigationController(rootViewController: addCardViewController)

        presentingViewController.present(navigationController, animated: true)
    }
}
