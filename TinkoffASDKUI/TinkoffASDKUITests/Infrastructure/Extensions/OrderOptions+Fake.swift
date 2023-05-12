//
//  OrderOptions+Fake.swift
//  TinkoffASDKUI-Unit-Tests
//
//  Created by Ivan Glushko on 20.04.2023.
//

@testable import TinkoffASDKUI

extension OrderOptions {

    static func fake() -> OrderOptions {
        OrderOptions(orderId: "123", amount: 100)
    }
}
