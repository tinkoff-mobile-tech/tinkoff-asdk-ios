//
//  YandexPayButtonContainerFactory.swift
//  TinkoffASDKYandexPay
//
//  Created by r.akhmadeev on 30.11.2022.
//

import Foundation
import TinkoffASDKCore
import TinkoffASDKUI
import YandexPaySDK

final class YandexPayButtonContainerFactory: IYandexPayButtonContainerFactory {
    private let sdkButtonFactory: IYandexPaySDKButtonFactory
    private let yandexPayPaymentFlowAssembly: IYandexPayPaymentFlowAssembly
    private let method: YandexPayMethod

    init(
        sdkButtonFactory: IYandexPaySDKButtonFactory,
        yandexPayPaymentFlowAssembly: IYandexPayPaymentFlowAssembly,
        method: YandexPayMethod
    ) {
        self.sdkButtonFactory = sdkButtonFactory
        self.yandexPayPaymentFlowAssembly = yandexPayPaymentFlowAssembly
        self.method = method
    }

    func createButtonContainer(
        with configuration: YandexPayButtonContainerConfiguration,
        delegate: YandexPayButtonContainerDelegate
    ) -> IYandexPayButtonContainer {
        YandexPayButtonContainer(
            configuration: configuration,
            sdkButtonFactory: sdkButtonFactory,
            paymentSheetFactory: YPPaymentSheetFactory(method: method),
            yandexPayPaymentFlowAssembly: yandexPayPaymentFlowAssembly,
            delegate: delegate
        )
    }
}
