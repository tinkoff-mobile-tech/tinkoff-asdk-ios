//
//  IRecurrentPaymentAssembly.swift
//  TinkoffASDKUI
//
//  Created by Aleksandr Pravosudov on 03.03.2023.
//

import TinkoffASDKCore
import UIKit

protocol IRecurrentPaymentAssembly {
    func build(
        paymentFlow: PaymentFlow,
        amount: Int64,
        rebillId: String,
        failureDelegate: IRecurrentPaymentFailiureDelegate?,
        moduleCompletion: PaymentResultCompletion?
    ) -> UIViewController
}
