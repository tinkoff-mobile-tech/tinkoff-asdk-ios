//
//  ISBPPaymentSheetAssembly.swift
//  TinkoffASDKUI
//
//  Created by Aleksandr Pravosudov on 17.01.2023.
//

import UIKit

protocol ISBPPaymentSheetAssembly {
    func build(paymentId: String, output: ISBPPaymentSheetPresenterOutput?) -> UIViewController
}
