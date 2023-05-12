//
//  YandexPayButtonContainerFactoryInitializer.swift
//  TinkoffASDKYandexPay
//
//  Created by r.akhmadeev on 19.12.2022.
//

import Foundation
import TinkoffASDKCore
import TinkoffASDKUI
import YandexPaySDK

final class YandexPayButtonContainerFactoryInitializer: IYandexPayButtonContainerFactoryInitializer {
    private let yandexPaySDK: IYandexPaySDKFacade

    init(yandexPaySDK: IYandexPaySDKFacade = YandexPaySDKFacade()) {
        self.yandexPaySDK = yandexPaySDK
    }

    func initializeButtonFactory(
        with configuration: TinkoffASDKUI.YandexPaySDKConfiguration,
        method: YandexPayMethod,
        flowAssembly: IYandexPayPaymentFlowAssembly
    ) throws -> IYandexPayButtonContainerFactory {
        try yandexPaySDK.initializeIfNeeded(with: configuration, method: method)

        return YandexPayButtonContainerFactory(
            sdkButtonFactory: yandexPaySDK,
            yandexPayPaymentFlowAssembly: flowAssembly,
            method: method
        )
    }
}

// MARK: - IYandexPaySDKInitializable + Helpers

private extension IYandexPaySDKInitializable {
    func initializeIfNeeded(
        with configuration: TinkoffASDKUI.YandexPaySDKConfiguration,
        method: YandexPayMethod
    ) throws {
        guard !isInitialized else { return }

        let merchant = YandexPaySDKMerchant(
            id: method.showcaseId,
            name: method.merchantName,
            origin: method.merchantOrigin,
            url: method.merchantOrigin
        )

        let configuration = YandexPaySDK.YandexPaySDKConfiguration(
            environment: .from(configuration.environment),
            merchant: merchant,
            locale: .from(configuration.locale)
        )

        try initialize(configuration: configuration)
    }
}
