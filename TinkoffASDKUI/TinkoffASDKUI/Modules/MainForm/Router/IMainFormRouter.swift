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
        cardPaymentOutput: ICardPaymentPresenterModuleOutput?,
        cardScannerDelegate: ICardScannerDelegate?
    )

    func openCardPayment(
        paymentFlow: PaymentFlow,
        cards: [PaymentCard]?,
        output: ICardPaymentPresenterModuleOutput?,
        cardListOutput: ICardListPresenterOutput?,
        cardScannerDelegate: ICardScannerDelegate?
    )

    func openSBP(
        paymentFlow: PaymentFlow,
        banks: [SBPBank]?,
        output: ISBPBanksModuleOutput?,
        paymentSheetOutput: ISBPPaymentSheetPresenterOutput?
    )

    func openTinkoffPayLanding(completion: VoidBlock?)
}
