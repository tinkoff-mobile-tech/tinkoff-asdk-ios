//
//  GetPaymentStatePayload+Fake.swift
//  Pods
//
//  Created by Ivan Glushko on 20.04.2023.
//

import TinkoffASDKCore

extension GetPaymentStatePayload {

    static func fake(status: AcquiringStatus = .authorized) -> GetPaymentStatePayload {
        GetPaymentStatePayload(
            paymentId: "23432",
            amount: 123,
            orderId: "934",
            status: status
        )
    }
}
