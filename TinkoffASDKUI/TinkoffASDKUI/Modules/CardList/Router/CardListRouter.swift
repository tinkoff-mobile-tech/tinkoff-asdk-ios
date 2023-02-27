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
    private let cardPaymentAssembly: ICardPaymentAssembly

    // MARK: Init

    init(addNewCardAssembly: IAddNewCardAssembly, cardPaymentAssembly: ICardPaymentAssembly) {
        self.addNewCardAssembly = addNewCardAssembly
        self.cardPaymentAssembly = cardPaymentAssembly
    }

    // MARK: ICardListRouter

    func openAddNewCard(customerKey: String, output: IAddNewCardPresenterOutput?) {
        let viewController = addNewCardAssembly.addNewCardView(customerKey: customerKey, output: output)
        transitionHandler?.navigationController?.pushViewController(viewController, animated: true)
    }

    func openCardPayment() {}
}
