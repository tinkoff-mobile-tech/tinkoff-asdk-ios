//
//  FinishPaymentOptions+Fake.swift
//  Pods
//
//  Created by Ivan Glushko on 20.04.2023.
//

@testable import TinkoffASDKUI

extension FinishPaymentOptions {

    static func fake() -> FinishPaymentOptions {
        FinishPaymentOptions(paymentId: "32432", amount: 200, orderId: "4234")
    }
}
