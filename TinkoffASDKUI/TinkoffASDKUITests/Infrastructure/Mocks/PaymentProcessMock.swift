//
//  PaymentProcessMock.swift
//  TinkoffASDKUI-Unit-Tests
//
//  Created by Ivan Glushko on 19.04.2023.
//

import TinkoffASDKCore
import TinkoffASDKUI

final class PaymentProcessMock: IPaymentProcess {

    var paymentId: String?
    var paymentFlow: PaymentFlow {
        get { return underlyingPaymentFlow }
        set(value) { underlyingPaymentFlow = value }
    }

    var underlyingPaymentFlow: PaymentFlow!
    var paymentSource: PaymentSourceData {
        get { return underlyingPaymentSource }
        set(value) { underlyingPaymentSource = value }
    }

    var underlyingPaymentSource: PaymentSourceData!

    // MARK: - start

    var startCallsCount = 0

    func start() {
        startCallsCount += 1
    }

    // MARK: - cancel

    var cancelCallsCount = 0

    func cancel() {
        cancelCallsCount += 1
    }
}
