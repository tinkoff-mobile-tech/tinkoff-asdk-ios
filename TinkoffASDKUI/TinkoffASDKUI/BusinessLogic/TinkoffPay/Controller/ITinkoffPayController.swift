//
//  ITinkoffPayController.swift
//  TinkoffASDKUI
//
//  Created by r.akhmadeev on 02.03.2023.
//

import Foundation

protocol ITinkoffPayController {
    func performPayment(paymentFlow: PaymentFlow, version: String)
}
