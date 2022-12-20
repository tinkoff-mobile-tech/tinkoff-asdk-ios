//
//  AcquiringUISDK+YandexPaySDK.swift
//  TinkoffASDKYandexPay
//
//  Created by r.akhmadeev on 18.12.2022.
//

import TinkoffASDKCore
import TinkoffASDKUI
import YandexPaySDK

public extension AcquiringUISDK {
    func yandexPayButtonContainerFactory(
        with configuration: TinkoffASDKUI.YandexPaySDKConfiguration,
        completion: @escaping (Result<IYandexPayButtonContainerFactory, Error>) -> Void
    ) {
        yandexPayButtonContainerFactory(
            with: configuration,
            initializer: YandexPayButtonContainerFactoryInitializer(),
            completion: completion
        )
    }
}
