//
//  IYandexPayPaymentSheetOutput.swift
//  TinkoffASDKUI
//
//  Created by r.akhmadeev on 18.12.2022.
//

import Foundation

protocol IYandexPayPaymentSheetOutput: AnyObject {
    /// Результат проведенного платежа на стороне Тинькофф
    func yandexPayPaymentSheet(completedWith result: PaymentResult)
}
