//
//  ISBPQrAssembly.swift
//  TinkoffASDKUI
//
//  Created by Aleksandr Pravosudov on 14.03.2023.
//

import UIKit

protocol ISBPQrAssembly {
    func buildForStaticQr(moduleCompletion: VoidBlock?) -> UIViewController
    func buildForDynamicQr(paymentFlow: PaymentFlow, moduleCompletion: PaymentResultCompletion?) -> UIViewController
}
