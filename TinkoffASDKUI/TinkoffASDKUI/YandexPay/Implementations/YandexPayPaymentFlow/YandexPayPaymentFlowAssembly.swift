//
//  YandexPayPaymentFlowAssembly.swift
//  TinkoffASDKUI
//
//  Created by r.akhmadeev on 19.12.2022.
//

import Foundation

final class YandexPayPaymentFlowAssembly: IYandexPayPaymentFlowAssembly {
    private let yandexPayActivityAssebmly: IYandexPayPaymentActivityAssembly

    init(yandexPayActivityAssebmly: IYandexPayPaymentActivityAssembly) {
        self.yandexPayActivityAssebmly = yandexPayActivityAssebmly
    }

    func yandexPayPaymentFlow() -> IYandexPayPaymentFlow {
        YandexPayPaymentFlow(paymentActivityAssembly: yandexPayActivityAssebmly)
    }
}
