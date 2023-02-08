//
//  IMainFormRouter.swift
//  TinkoffASDKUI
//
//  Created by r.akhmadeev on 19.01.2023.
//

import Foundation
import TinkoffASDKCore

protocol IMainFormRouter {
    func openCardPaymentForm(paymentFlow: PaymentFlow, cards: [PaymentCard], output: ICardPaymentPresenterModuleOutput?)
    func openTinkoffPay(paymentFlow: PaymentFlow)
    func openSBP(paymentFlow: PaymentFlow)
}
