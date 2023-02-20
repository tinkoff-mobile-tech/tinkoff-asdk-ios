//
//  FullPaymentData.swift
//  TinkoffASDKUI
//
//  Created by Aleksandr Pravosudov on 09.02.2023.
//

import TinkoffASDKCore

struct FullPaymentData {
    let paymentProcess: PaymentProcess
    var payload: GetPaymentStatePayload
    let cardId: String?
    let rebillId: String?

    func update(payload: GetPaymentStatePayload) -> FullPaymentData {
        FullPaymentData(paymentProcess: paymentProcess, payload: payload, cardId: cardId, rebillId: rebillId)
    }
}
