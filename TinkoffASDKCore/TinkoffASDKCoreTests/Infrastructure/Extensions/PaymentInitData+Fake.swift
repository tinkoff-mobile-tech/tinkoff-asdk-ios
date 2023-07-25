//
//  PaymentInitData+Fake.swift
//  TinkoffASDKCore-Unit-Tests
//
//  Created by Никита Васильев on 21.07.2023.
//

import Foundation
@testable import TinkoffASDKCore

extension PaymentInitData {
    static func fake() -> PaymentInitData {
        PaymentInitData(amount: Int64(5000), orderId: "order_id", customerKey: "key")
    }
}
