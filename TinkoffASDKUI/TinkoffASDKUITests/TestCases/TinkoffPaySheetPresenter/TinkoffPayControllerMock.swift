//
//  TinkoffPayControllerMock.swift
//  TinkoffASDKUI-Unit-Tests
//
//  Created by Никита Васильев on 29.05.2023.
//

import TinkoffASDKCore
@testable import TinkoffASDKUI

final class TinkoffPayControllerMock: ITinkoffPayController {
    var invokedGetDelegate = false
    var invokedGetDelegateCount = 0
    var invokedSetDelegate = false
    var invokedSetDelegateCount = 0
    var stubbedDelegate: TinkoffPayControllerDelegate?

    var delegate: TinkoffASDKUI.TinkoffPayControllerDelegate? {
        get {
            invokedGetDelegate = true
            invokedGetDelegateCount += 1
            return stubbedDelegate
        }
        set {
            invokedSetDelegate = true
            invokedSetDelegateCount += 1
        }
    }

    var invokedPerformPayment = false
    var invokedPerformPaymentCount = 0
    var invokedPerformPaymentParameters: (paymentFlow: PaymentFlow, method: TinkoffPayMethod)?
    var invokedPerformPaymentParametersList = [(paymentFlow: PaymentFlow, method: TinkoffPayMethod)]()

    func performPayment(
        paymentFlow: TinkoffASDKUI.PaymentFlow,
        method: TinkoffASDKCore.TinkoffPayMethod
    ) -> TinkoffASDKCore.Cancellable {
        invokedPerformPayment = true
        invokedPerformPaymentCount += 1
        invokedPerformPaymentParameters = (paymentFlow, method)
        invokedPerformPaymentParametersList.append((paymentFlow, method))
        return CancellableMock()
    }
}
