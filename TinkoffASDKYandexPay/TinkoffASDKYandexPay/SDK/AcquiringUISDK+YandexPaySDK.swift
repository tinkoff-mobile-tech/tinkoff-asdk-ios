//
//  AcquiringUISDK+YandexPaySDK.swift
//  TinkoffASDKYandexPay
//
//  Created by r.akhmadeev on 18.12.2022.
//

import TinkoffASDKUI

public extension AcquiringUISDK {
    /// Асинхронное создание фабрики `IYandexPayButtonContainerFactory`
    ///
    /// Ссылку на полученный таким образом объект можно хранить переиспользовать множество раз в различных точках приложения.
    /// - Parameters:
    ///   - configuration: Общаяя конфигурация `YandexPay`
    ///   - completion: Callback с результатом создания фабрики. Вернет `Error` при сетевых ошибках или если способ оплаты через `YandexPay` недоступен для данного терминала.
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
