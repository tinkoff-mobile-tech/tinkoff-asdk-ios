//
//  IYandexPayButtonContainerFactoryInitializer.swift
//  TinkoffASDKUI
//
//  Created by r.akhmadeev on 19.12.2022.
//

import Foundation
import TinkoffASDKCore

/// Создает фабрику, инициализируя `YandexPaySDK`
public protocol IYandexPayButtonContainerFactoryInitializer {
    func initializeButtonFactory(
        with configuration: YandexPaySDKConfiguration,
        method: YandexPayMethod,
        flowAssembly: IYandexPayPaymentFlowAssembly
    ) throws -> IYandexPayButtonContainerFactory
}
