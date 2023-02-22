//
//  CardListRouter.swift
//  TinkoffASDKUI
//
//  Created by r.akhmadeev on 22.02.2023.
//

import UIKit

final class CardListRouter: ICardListRouter {
    // MARK: Dependencies

    weak var transitionHandler: UIViewController?
    private let addNewCardAssembly: IAddNewCardAssembly

    // MARK: Init

    init(addNewCardAssembly: IAddNewCardAssembly) {
        self.addNewCardAssembly = addNewCardAssembly
    }

    // MARK: ICardListRouter

    func openAddNewCard(customerKey: String, output: IAddNewCardPresenterOutput?) {
        let viewController = addNewCardAssembly.addNewCardView(customerKey: customerKey, output: output)
        transitionHandler?.navigationController?.pushViewController(viewController, animated: true)
    }
}
