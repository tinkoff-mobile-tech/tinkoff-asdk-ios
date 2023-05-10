//
//  FinishAuthorizePayload+Fake.swift
//  Pods
//
//  Created by Ivan Glushko on 20.04.2023.
//

import TinkoffASDKCore

extension FinishAuthorizePayload {

    static func fake(responseStatus: PaymentFinishResponseStatus) -> FinishAuthorizePayload {
        FinishAuthorizePayload(
            status: .authorized,
            paymentState: .fake(),
            responseStatus: responseStatus
        )
    }
}
