//
//  Submit3DSAuthorizationV2Data.swift
//  TinkoffASDKCore
//
//  Created by Ivan Glushko on 31.10.2022.
//

import Foundation

public enum Submit3DSAuthorizationV2Flow {
    case payment
    case attachCard
}

public struct Submit3DSAuthorizationV2Data {

    /// for attachCard flow
    public let cres: String?

    /// for requests from payment 3ds webview v2 version
    public let paymentId: String?

    public init(
        cres: String?,
        paymentId: String?
    ) {
        self.cres = cres
        self.paymentId = paymentId
    }
}

public extension Submit3DSAuthorizationV2Data {

    static func assembleForPaymentFlow(paymentId: String) -> Self {
        Self(cres: nil, paymentId: paymentId)
    }

    static func assembleForAttachCardFlow(cres: String) -> Self {
        Self(cres: cres, paymentId: nil)
    }
}
