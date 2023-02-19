//
//  IPaymentController.swift
//  TinkoffASDKUI
//
//  Created by r.akhmadeev on 19.02.2023.
//

import Foundation
import TinkoffASDKCore

public protocol IPaymentController: AnyObject {
    var delegate: PaymentControllerDelegate? { get set }
    var dataSource: PaymentControllerDataSource? { get set }
    var webFlowDelegate: ThreeDSWebFlowDelegate? { get set }

    func performPayment(paymentFlow: PaymentFlow, paymentSource: PaymentSourceData)
}

// MARK: - IPaymentController + Helpers

public extension IPaymentController {
    func performInitPayment(paymentOptions: PaymentOptions, paymentSource: PaymentSourceData) {
        performPayment(paymentFlow: .full(paymentOptions: paymentOptions), paymentSource: paymentSource)
    }

    func performFinishPayment(
        paymentId: String,
        paymentSource: PaymentSourceData,
        customerOptions: CustomerOptions?
    ) {
        performPayment(
            paymentFlow: .finish(paymentId: paymentId, customerOptions: customerOptions),
            paymentSource: paymentSource
        )
    }
}
