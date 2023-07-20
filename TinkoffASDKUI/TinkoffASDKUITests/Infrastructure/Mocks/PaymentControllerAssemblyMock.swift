//
//  PaymentControllerAssemblyMock.swift
//  Pods
//
//  Created by Ivan Glushko on 25.05.2023.
//

@testable import TinkoffASDKUI

final class PaymentControllerAssemblyMock: IPaymentControllerAssembly {

    // MARK: - paymentController

    var paymentControllerCallsCount = 0
    var paymentControllerReturnValue: IPaymentController!

    func paymentController() -> IPaymentController {
        paymentControllerCallsCount += 1
        return paymentControllerReturnValue
    }
}

// MARK: - Resets

extension PaymentControllerAssemblyMock {
    func fullReset() {
        paymentControllerCallsCount = 0
    }
}
