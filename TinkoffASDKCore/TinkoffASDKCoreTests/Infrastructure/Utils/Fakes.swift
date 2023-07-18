//
//  Fakes.swift
//  TinkoffASDKCore-Unit-Tests
//
//  Created by Aleksandr Pravosudov on 18.07.2023.
//

import TinkoffASDKCore

extension GetPaymentStatePayload {
    static func fake(status: AcquiringStatus = .authorized) -> GetPaymentStatePayload {
        GetPaymentStatePayload(paymentId: "121111", amount: 234, orderId: "324234", status: status)
    }
}

extension FinishAuthorizePayload {
    static func fake(responseStatus: PaymentFinishResponseStatus) -> FinishAuthorizePayload {
        FinishAuthorizePayload(
            status: .authorized,
            paymentState: .fake(),
            responseStatus: responseStatus
        )
    }
}
