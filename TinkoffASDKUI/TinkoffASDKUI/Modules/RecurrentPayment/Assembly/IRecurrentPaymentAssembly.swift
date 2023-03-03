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
        paymentSource: PaymentSourceData,
        configuration: MainFormUIConfiguration,
        moduleCompletion: PaymentResultCompletion?
    ) -> UIViewController
}
