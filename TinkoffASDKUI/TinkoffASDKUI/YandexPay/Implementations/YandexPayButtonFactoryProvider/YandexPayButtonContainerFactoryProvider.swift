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
    private let methodLoader: IYandexPayMethodProvider

    // MARK: Init

    init(flowAssembly: IYandexPayPaymentFlowAssembly, methodLoader: IYandexPayMethodProvider) {
        self.flowAssembly = flowAssembly
        self.methodLoader = methodLoader
    }

    // MARK: IYandexPayButtonContainerFactoryProvider

    func yandexPayButtonContainerFactory(
        with configuration: YandexPaySDKConfiguration,
        initializer: IYandexPayButtonContainerFactoryInitializer,
        completion: @escaping (Result<IYandexPayButtonContainerFactory, Error>) -> Void
    ) {
        methodLoader.provideMethod { [flowAssembly] result in
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
