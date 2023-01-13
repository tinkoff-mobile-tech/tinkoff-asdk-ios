//
//  IYandexPayButtonContainerFactoryProvider.swift
//  TinkoffASDKUI
//
//  Created by r.akhmadeev on 19.12.2022.
//

import Foundation

protocol IYandexPayButtonContainerFactoryProvider {
    func yandexPayButtonContainerFactory(
        with configuration: YandexPaySDKConfiguration,
        initializer: IYandexPayButtonContainerFactoryInitializer,
        completion: @escaping (Result<IYandexPayButtonContainerFactory, Error>) -> Void
    )
}
