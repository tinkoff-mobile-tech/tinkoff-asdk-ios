//
//  PaymentFactoryMock.swift
//  TinkoffASDKUI-Unit-Tests
//
//  Created by Ivan Glushko on 16.10.2022.
//

import TinkoffASDKCore
@testable import TinkoffASDKUI

final class PaymentFactoryMock: IPaymentFactory {

    // MARK: - createPayment

    struct CreatePaymentArguments {
        let paymentSource: PaymentSourceData
        let paymentFlow: PaymentFlow
        let paymentDelegate: PaymentProcessDelegate
    }

    var createPaymentCallCounter = 0
    var createPaymentPassedArguments: CreatePaymentArguments?
    var createPaymentStubReturn: IPaymentProcess?

    func createPayment(
        paymentSource: PaymentSourceData,
        paymentFlow: PaymentFlow,
        paymentDelegate: PaymentProcessDelegate
    ) -> IPaymentProcess? {
        createPaymentCallCounter += 1
        createPaymentPassedArguments = CreatePaymentArguments(
            paymentSource: paymentSource,
            paymentFlow: paymentFlow,
            paymentDelegate: paymentDelegate
        )

        return createPaymentStubReturn
    }
}
