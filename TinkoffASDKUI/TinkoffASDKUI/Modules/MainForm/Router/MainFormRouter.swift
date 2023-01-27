//
//  MainFormRouter.swift
//  TinkoffASDKUI
//
//  Created by r.akhmadeev on 19.01.2023.
//

import TinkoffASDKCore
import UIKit

final class MainFormRouter: IMainFormRouter {
    // MARK: Dependencies

    weak var transitionHandler: UIViewController?
    private let configuration: MainFormUIConfiguration

    // MARK: Init

    init(configuration: MainFormUIConfiguration) {
        self.configuration = configuration
    }

    // MARK: IMainFormRouter

    func openCardPaymentForm(paymentFlow: PaymentFlow, cards: [PaymentCard]) {}
}
