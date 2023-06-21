//
//  AttachCardPayload+Fake.swift
//  Pods
//
//  Created by Ivan Glushko on 30.05.2023.
//

@testable import TinkoffASDKCore

extension AttachCardPayload {

    static func fake(status: AcquiringStatus = .unknown, attachCardStatus: AttachCardStatus) -> AttachCardPayload {
        AttachCardPayload(
            status: status,
            requestKey: "requestKey",
            cardId: "cardId",
            rebillId: "rebillId",
            attachCardStatus: attachCardStatus
        )
    }
}
