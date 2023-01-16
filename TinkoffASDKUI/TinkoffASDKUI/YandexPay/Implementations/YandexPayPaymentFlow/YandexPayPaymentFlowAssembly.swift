//
//  YandexPayPaymentFlowAssembly.swift
//  TinkoffASDKUI
//
//  Created by r.akhmadeev on 19.12.2022.
//

import Foundation

final class YandexPayPaymentFlowAssembly: IYandexPayPaymentFlowAssembly {
    private let yandexPayActivityAssebmly: IYandexPayPaymentSheetAssembly

    init(yandexPayActivityAssebmly: IYandexPayPaymentSheetAssembly) {
        self.yandexPayActivityAssebmly = yandexPayActivityAssebmly
    }

    func yandexPayPaymentFlow(delegate: IYandexPayPaymentFlowOutput) -> IYandexPayPaymentFlow {
        YandexPayPaymentFlow(paymentActivityAssembly: yandexPayActivityAssebmly, delegate: delegate)
    }
}
