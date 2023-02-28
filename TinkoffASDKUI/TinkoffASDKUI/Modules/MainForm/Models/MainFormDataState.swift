//
//  MainFormDataState.swift
//  TinkoffASDKUI
//
//  Created by r.akhmadeev on 26.02.2023.
//

import Foundation
import TinkoffASDKCore

struct MainFormDataState {
    let primaryPaymentMethod: MainFormPaymentMethod
    let otherPaymentMethods: [MainFormPaymentMethod]
    var cards: [PaymentCard]?
    var sbpBanks: (allBanks: [SBPBank], preferredBanks: [SBPBank])?
}

extension MainFormDataState {
    static var initial: MainFormDataState {
        MainFormDataState(
            primaryPaymentMethod: .card,
            otherPaymentMethods: [],
            cards: nil,
            sbpBanks: nil
        )
    }
}
