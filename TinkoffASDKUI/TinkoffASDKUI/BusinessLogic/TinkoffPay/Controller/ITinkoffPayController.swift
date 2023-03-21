//
//  ITinkoffPayController.swift
//  TinkoffASDKUI
//
//  Created by r.akhmadeev on 02.03.2023.
//

import Foundation
import TinkoffASDKCore

protocol ITinkoffPayController: AnyObject {
    var delegate: TinkoffPayControllerDelegate? { get set }

    @discardableResult
    func performPayment(paymentFlow: PaymentFlow, method: TinkoffPayMethod) -> Cancellable
}
