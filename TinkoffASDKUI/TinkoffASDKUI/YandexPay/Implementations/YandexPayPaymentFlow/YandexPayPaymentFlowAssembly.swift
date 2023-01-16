//
//  YandexPayPaymentFlowAssembly.swift
//  TinkoffASDKUI
//
//  Created by r.akhmadeev on 19.12.2022.
//

import Foundation

final class YandexPayPaymentFlowAssembly: IYandexPayPaymentFlowAssembly {
    private let yandexPayPaymentSheetAssembly: IYandexPayPaymentSheetAssembly

    init(yandexPayPaymentSheetAssembly: IYandexPayPaymentSheetAssembly) {
        self.yandexPayPaymentSheetAssembly = yandexPayPaymentSheetAssembly
    }

    func yandexPayPaymentFlow(delegate: YandexPayPaymentFlowDelegate) -> IYandexPayPaymentFlow {
        YandexPayPaymentFlow(yandexPayPaymentSheetAssembly: yandexPayPaymentSheetAssembly, delegate: delegate)
    }
}
