//
//  IMainFormRouter.swift
//  TinkoffASDKUI
//
//  Created by r.akhmadeev on 19.01.2023.
//

import Foundation
import TinkoffASDKCore

protocol IMainFormRouter {
    func openCardPaymentList(
        paymentFlow: PaymentFlow,
        cards: [PaymentCard],
        selectedCard: PaymentCard,
        cardListOutput: ICardListPresenterOutput?,
        cardPaymentOutput: ICardPaymentPresenterModuleOutput?
    )

    func openCardPayment(
        paymentFlow: PaymentFlow,
        cards: [PaymentCard]?,
        output: ICardPaymentPresenterModuleOutput?
    )

    func openSBP(
        paymentFlow: PaymentFlow,
        banks: [SBPBank]?,
        paymentSheetOutput: ISBPPaymentSheetPresenterOutput?
    )
}
