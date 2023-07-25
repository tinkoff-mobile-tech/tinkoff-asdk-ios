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

    typealias CreatePaymentArguments = (paymentSource: PaymentSourceData, paymentFlow: PaymentFlow, paymentDelegate: PaymentProcessDelegate)

    var createPaymentCallsCount = 0
    var createPaymentReceivedArguments: CreatePaymentArguments?
    var createPaymentReceivedInvocations: [CreatePaymentArguments?] = []
    var createPaymentReturnValue: IPaymentProcess?

    func createPayment(paymentSource: PaymentSourceData, paymentFlow: PaymentFlow, paymentDelegate: PaymentProcessDelegate) -> IPaymentProcess? {
        createPaymentCallsCount += 1
        let arguments = (paymentSource, paymentFlow, paymentDelegate)
        createPaymentReceivedArguments = arguments
        createPaymentReceivedInvocations.append(arguments)
        return createPaymentReturnValue
    }
}

// MARK: - Resets

extension PaymentFactoryMock {
    func fullReset() {
        createPaymentCallsCount = 0
        createPaymentReceivedArguments = nil
        createPaymentReceivedInvocations = []
    }
}
