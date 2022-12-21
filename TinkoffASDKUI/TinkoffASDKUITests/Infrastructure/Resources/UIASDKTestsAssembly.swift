//
//  UIASDKTestsAssembly.swift
//  TinkoffASDKUI
//
//  Created by Ivan Glushko on 19.10.2022.
//

import TinkoffASDKCore
import TinkoffASDKUI

final class UIASDKTestsAssembly {

    static func makePaymentOptions() -> PaymentOptions {
        return PaymentOptions(
            orderOptions: OrderOptions(
                orderId: "2323266562",
                amount: 324
            ),
            customerOptions: CustomerOptions(
                customerKey: "me1",
                email: "some@mail.com"
            )
        )
    }

    static func makePaymentSourceData_cardNumber() -> PaymentSourceData {
        PaymentSourceData.cardNumber(
            number: "2432424443242§",
            expDate: "11/33",
            cvv: "342"
        )
    }

    static func makePaymentSourceData_parentPayment() -> PaymentSourceData {
        PaymentSourceData.parentPayment(rebuidId: "234234")
    }
}
