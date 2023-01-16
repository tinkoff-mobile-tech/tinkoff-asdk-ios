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
    private let paymentFlowAssembly: IYandexPayPaymentFlowAssembly
    private let method: YandexPayMethod

    init(
        sdkButtonFactory: IYandexPaySDKButtonFactory,
        paymentFlowAssembly: IYandexPayPaymentFlowAssembly,
        method: YandexPayMethod
    ) {
        self.sdkButtonFactory = sdkButtonFactory
        self.paymentFlowAssembly = paymentFlowAssembly
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
            paymentFlowFactory: paymentFlowAssembly,
            delegate: delegate
        )
    }
}
