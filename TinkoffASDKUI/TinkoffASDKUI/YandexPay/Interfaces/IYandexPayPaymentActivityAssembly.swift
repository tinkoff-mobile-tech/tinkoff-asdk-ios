//
//  IYandexPayPaymentActivityAssembly.swift
//  TinkoffASDKUI
//
//  Created by r.akhmadeev on 19.12.2022.
//

import UIKit

protocol IYandexPayPaymentActivityAssembly {
    func yandexPayActivity(
        paymentOptions: PaymentOptions,
        base64Token: String,
        output: IYandexPayPaymentActivityOutput
    ) -> UIViewController
}
