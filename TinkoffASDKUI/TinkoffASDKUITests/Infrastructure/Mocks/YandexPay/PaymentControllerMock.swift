//
//  PaymentControllerMock.swift
//  Pods
//
//  Created by Ivan Glushko on 20.04.2023.
//

import TinkoffASDKCore
@testable import TinkoffASDKUI

final class PaymentControllerMock: IPaymentController {
    var delegate: PaymentControllerDelegate?
    var webFlowDelegate: (any ThreeDSWebFlowDelegate)?

    // MARK: - performPayment

    typealias PerformPaymentArguments = (paymentFlow: PaymentFlow, paymentSource: PaymentSourceData)

    var performPaymentCallsCount = 0
    var performPaymentReceivedArguments: PerformPaymentArguments?
    var performPaymentReceivedInvocations: [PerformPaymentArguments?] = []

    func performPayment(paymentFlow: PaymentFlow, paymentSource: PaymentSourceData) {
        performPaymentCallsCount += 1
        let arguments = (paymentFlow, paymentSource)
        performPaymentReceivedArguments = arguments
        performPaymentReceivedInvocations.append(arguments)
    }
}

// MARK: - Resets

extension PaymentControllerMock {
    func fullReset() {
        performPaymentCallsCount = 0
        performPaymentReceivedArguments = nil
        performPaymentReceivedInvocations = []
    }
}
