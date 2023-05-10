//
//  PaymentOptions+Fake.swift
//  TinkoffASDKUI-Unit-Tests
//
//  Created by Ivan Glushko on 20.04.2023.
//

@testable import TinkoffASDKUI

extension PaymentOptions {

    static func fake() -> PaymentOptions {
        PaymentOptions(orderOptions: OrderOptions.fake())
    }
}
