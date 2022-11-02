//
//  Submit3DSAuthorizationV2Data.swift
//  TinkoffASDKCore
//
//  Created by Ivan Glushko on 31.10.2022.
//

import Foundation

public struct Submit3DSAuthorizationV2Data {

    /// for app based 3ds flow
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
