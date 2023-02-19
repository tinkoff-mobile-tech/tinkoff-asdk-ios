//
//  IPaymentController.swift
//  TinkoffASDKUI
//
//  Created by r.akhmadeev on 19.02.2023.
//

import Foundation
import TinkoffASDKCore

protocol IPaymentController {
    func performPayment(paymentFlow: PaymentFlow, paymentSource: PaymentSourceData)
    func performInitPayment(paymentOptions: PaymentOptions, paymentSource: PaymentSourceData)
    func performFinishPayment(paymentId: String, paymentSource: PaymentSourceData, customerOptions: CustomerOptions?)
}
