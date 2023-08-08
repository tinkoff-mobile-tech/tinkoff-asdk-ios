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
        addCardOptions: AddCardOptions,
        output: IAddNewCardPresenterOutput?,
        cardScannerDelegate: ICardScannerDelegate?
    ) -> AddNewCardViewController {
        createModule(
            customerKey: customerKey,
            addCardOptions: addCardOptions,
            output: output,
            cardScannerDelegate: cardScannerDelegate,
            onViewWasClosed: nil
        )
    }

    func addNewCardNavigationController(
        customerKey: String,
        addCardOptions: AddCardOptions,
        cardScannerDelegate: ICardScannerDelegate?,
        onViewWasClosed: ((AddCardResult) -> Void)?
    ) -> UINavigationController {
        let viewController = createModule(
            customerKey: customerKey,
            addCardOptions: addCardOptions,
            output: nil,
            cardScannerDelegate: cardScannerDelegate,
            onViewWasClosed: onViewWasClosed
        )
        return UINavigationController.withElevationBar(rootViewController: viewController)
    }

    // MARK: Helpers

    private func createModule(
        customerKey: String,
        addCardOptions: AddCardOptions,
        output: IAddNewCardPresenterOutput?,
        cardScannerDelegate: ICardScannerDelegate?,
        onViewWasClosed: ((AddCardResult) -> Void)?
    ) -> AddNewCardViewController {
        let cardsController = cardsControllerAssembly.cardsController(
            customerKey: customerKey,
            addCardOptions: addCardOptions
        )

        let validator = CardRequisitesValidator()
        let paymentSystemResolver = PaymentSystemResolver()
        let bankResolver = BankResolver()
        let inputMaskResolver = CardRequisitesMasksResolver(paymentSystemResolver: paymentSystemResolver)

        let cardFieldPresenterAssembly = CardFieldPresenterAssembly(
            validator: validator,
            paymentSystemResolver: paymentSystemResolver,
            bankResolver: bankResolver,
            inputMaskResolver: inputMaskResolver
        )
        let cardFieldPresenter = cardFieldPresenterAssembly.build(isScanButtonNeeded: cardScannerDelegate != nil)

        let presenter = AddNewCardPresenter(
            addCardOptions: addCardOptions,
            cardsController: cardsController,
            output: output,
            onViewWasClosed: onViewWasClosed,
            cardFieldPresenter: cardFieldPresenter
        )

        cardFieldPresenter.injectOutput(presenter)

        let view = AddNewCardViewController(presenter: presenter, cardScannerDelegate: cardScannerDelegate)

        presenter.view = view
        cardsController.webFlowDelegate = view

        return view
    }
}
