//
//  GetAddCardStatePayload+Fake.swift
//  Payments
//
//  Created by Ivan Glushko on 03.04.2023
//

import TinkoffASDKCore

extension GetAddCardStatePayload {

    static func fake(status: AcquiringStatus) -> Self {
        GetAddCardStatePayload(
            requestKey: "requestKey",
            status: status,
            cardId: "234234",
            rebillId: ""
        )
    }
}
