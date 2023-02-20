//
//  IYandexPayPaymentSheetOutput.swift
//  TinkoffASDKUI
//
//  Created by r.akhmadeev on 18.12.2022.
//

import Foundation

protocol IYandexPayPaymentSheetOutput: AnyObject {
    func yandexPayPaymentSheet(completedWith result: PaymentResult)
}
