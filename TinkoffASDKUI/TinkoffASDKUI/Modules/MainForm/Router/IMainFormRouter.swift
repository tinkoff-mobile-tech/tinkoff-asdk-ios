//
//  IMainFormRouter.swift
//  TinkoffASDKUI
//
//  Created by r.akhmadeev on 19.01.2023.
//

import Foundation
import TinkoffASDKCore

protocol IMainFormRouter {
    func openCardSelection(paymentFlow: PaymentFlow, cards: [PaymentCard], selectedCard: PaymentCard, output: ICardListPresenterOutput?)
    func pushNewCardPaymentToCardSelection(paymentFlow: PaymentFlow, output: ICardPaymentPresenterModuleOutput?)
    func closeCardSelection(completion: VoidBlock?)
    func openCardPayment(paymentFlow: PaymentFlow, cards: [PaymentCard]?, output: ICardPaymentPresenterModuleOutput?)
    func openTinkoffPay(paymentFlow: PaymentFlow)
    func openSBP(paymentFlow: PaymentFlow, paymentSheetOutput: ISBPPaymentSheetPresenterOutput?)
}

extension IMainFormRouter {
    func closeCardSelection() {
        closeCardSelection(completion: nil)
    }
}
