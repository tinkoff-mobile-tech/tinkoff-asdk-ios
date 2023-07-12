//
//  TinkoffPayControllerMock.swift
//  TinkoffASDKUI-Unit-Tests
//
//  Created by Никита Васильев on 29.05.2023.
//

import TinkoffASDKCore
@testable import TinkoffASDKUI

final class TinkoffPayControllerMock: ITinkoffPayController {
    var delegate: TinkoffPayControllerDelegate?

    // MARK: - performPayment

    typealias PerformPaymentArguments = (paymentFlow: PaymentFlow, method: TinkoffPayMethod)

    var performPaymentCallsCount = 0
    var performPaymentReceivedArguments: PerformPaymentArguments?
    var performPaymentReceivedInvocations: [PerformPaymentArguments] = []
    var performPaymentReturnValue: Cancellable = CancellableMock()

    @discardableResult
    func performPayment(paymentFlow: PaymentFlow, method: TinkoffPayMethod) -> Cancellable {
        performPaymentCallsCount += 1
        let arguments = (paymentFlow, method)
        performPaymentReceivedArguments = arguments
        performPaymentReceivedInvocations.append(arguments)
        return performPaymentReturnValue
    }
}

// MARK: - Resets

extension TinkoffPayControllerMock {
    func fullReset() {
        performPaymentCallsCount = 0
        performPaymentReceivedArguments = nil
        performPaymentReceivedInvocations = []
    }
}
