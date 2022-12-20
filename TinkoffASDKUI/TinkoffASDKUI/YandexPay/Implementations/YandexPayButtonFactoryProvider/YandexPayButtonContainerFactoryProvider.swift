//
//  YandexPayButtonContainerFactoryProvider.swift
//  TinkoffASDKUI
//
//  Created by r.akhmadeev on 18.12.2022.
//

import Foundation
import TinkoffASDKCore

final class YandexPayButtonContainerFactoryProvider: IYandexPayButtonContainerFactoryProvider {
    // MARK: Dependencies

    private let flowAssembly: IYandexPayPaymentFlowAssembly
    private let methodProvider: IYandexPayMethodProvider

    // MARK: Init

    init(flowAssembly: IYandexPayPaymentFlowAssembly, methodProvider: IYandexPayMethodProvider) {
        self.flowAssembly = flowAssembly
        self.methodProvider = methodProvider
    }

    // MARK: IYandexPayButtonContainerFactoryProvider

    func yandexPayButtonContainerFactory(
        with configuration: YandexPaySDKConfiguration,
        initializer: IYandexPayButtonContainerFactoryInitializer,
        completion: @escaping (Result<IYandexPayButtonContainerFactory, Error>) -> Void
    ) {
        methodProvider.provideMethod { [flowAssembly] result in
            DispatchQueue.performOnMain {
                let factoryResult = result.tryMap { method in
                    try initializer.initializeButtonFactory(
                        with: configuration,
                        method: method,
                        flowAssembly: flowAssembly
                    )
                }
                completion(factoryResult)
            }
        }
    }
}
