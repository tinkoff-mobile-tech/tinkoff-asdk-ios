//
//  MockPaymentProcess.swift
//  TinkoffASDKCore
//
//  Created by Ivan Glushko on 18.10.2022.
//

import TinkoffASDKCore
@testable import TinkoffASDKUI

final class MockPaymentProcess: PaymentProcess {

    var paymentId: String?

    var paymentFlow: PaymentFlow

    var paymentSource: PaymentSourceData

    // MARK: - Init

    init(
        paymentId: String? = nil,
        paymentFlow: PaymentFlow,
        paymentSource: PaymentSourceData
    ) {
        self.paymentId = paymentId
        self.paymentFlow = paymentFlow
        self.paymentSource = paymentSource
    }

    // MARK: - start

    var startCallCounter = 0

    func start() {
        startCallCounter += 1
    }

    // MARK: - cancel

    var cancelCallCounter = 0

    func cancel() {
        cancelCallCounter += 1
    }
}
