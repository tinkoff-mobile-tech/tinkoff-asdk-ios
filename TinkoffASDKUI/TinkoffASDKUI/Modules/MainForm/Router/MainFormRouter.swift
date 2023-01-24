//
//  MainFormRouter.swift
//  TinkoffASDKUI
//
//  Created by r.akhmadeev on 19.01.2023.
//

import UIKit

final class MainFormRouter: IMainFormRouter {

    // MARK: Dependencies

    weak var transitionHandler: UIViewController?
    private let cardPaymentAssembly: ICardPaymentAssembly

    // MARK: Initialization

    init(cardPaymentAssembly: ICardPaymentAssembly) {
        self.cardPaymentAssembly = cardPaymentAssembly
    }
}

// MARK: - IMainFormRouter

extension MainFormRouter {
    func openCardPaymentForm() {
        let cardPaymentVC = cardPaymentAssembly.build()
        let navVC = UINavigationController(rootViewController: cardPaymentVC)
        transitionHandler?.present(navVC, animated: true, completion: nil)
    }
}
