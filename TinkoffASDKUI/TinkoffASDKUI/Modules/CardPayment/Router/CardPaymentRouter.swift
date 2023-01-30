//
//  CardPaymentRouter.swift
//  TinkoffASDKUI
//
//  Created by Aleksandr Pravosudov on 20.01.2023.
//

import UIKit

final class CardPaymentRouter: ICardPaymentRouter {

    // MARK: Dependencies

    weak var transitionHandler: UIViewController?
}

// MARK: - ICardPaymentRouter

extension CardPaymentRouter {
    func closeScreen() {
        transitionHandler?.dismiss(animated: true)
    }
}
