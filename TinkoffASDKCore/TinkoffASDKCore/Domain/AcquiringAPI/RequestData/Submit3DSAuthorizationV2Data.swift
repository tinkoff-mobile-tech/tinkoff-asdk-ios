//
//  Submit3DSAuthorizationV2Data.swift
//  TinkoffASDKCore
//
//  Created by Ivan Glushko on 31.10.2022.
//

import Foundation

public enum Submit3DSAuthorizationV2Data {

    /// for attachCard flow
    case attachCardFlow(data: AttachCardData)

    /// for requests from payment 3ds webview v2 version
    case paymentFlow(data: PaymentData)
}

public extension Submit3DSAuthorizationV2Data {

    struct AttachCardData {

        public let cres: String

        public init(cres: String) {
            self.cres = cres
        }
    }

    struct PaymentData {

        public let paymentId: String

        public init(paymentId: String) {
            self.paymentId = paymentId
        }
    }
}
