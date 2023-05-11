//
//  InitPayload+Fake.swift
//  Pods
//
//  Created by Ivan Glushko on 21.04.2023.
//

import TinkoffASDKCore

extension InitPayload {

    static func fake(status: AcquiringStatus = .authorized) -> InitPayload {
        InitPayload(
            amount: 100,
            orderId: "445",
            paymentId: "34243",
            status: status
        )
    }
}
