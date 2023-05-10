//
//  PaymentFlow+Fake.swift
//  TinkoffASDKUI-Unit-Tests
//
//  Created by Ivan Glushko on 20.04.2023.
//

@testable import TinkoffASDKUI

extension PaymentFlow {

    static func fake() -> PaymentFlow {
        .full(paymentOptions: .fake())
    }
}
