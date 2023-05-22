//
//
//  YandexPayHelper.swift
//
//  Copyright (c) 2021 Tinkoff Bank
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//   http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import SnapshotTesting
import TinkoffASDKCore
import TinkoffASDKUI
import XCTest

@testable import ASDKSample
@testable import TestsSharedInfrastructure
@testable import TinkoffASDKYandexPay

final class YandexPayHelper {

    struct ButtonsResult {
        let full: IYandexPayButtonContainer
        let compact: IYandexPayButtonContainer
    }

    /// Создает 2 кнопки яндекс пей с разной шириной (узкую и длинную)
    static func getYandexPayButtons(locale: YandexPaySDKConfiguration.Locale) throws -> ButtonsResult {
        let fullButton = try createYandexButton(locale: locale)
        let compactButton = try createYandexButton(locale: locale)
        fullButton.frame.size = CGSize(width: 326, height: 52)
        compactButton.frame.size = CGSize(width: 262, height: 52)
        return ButtonsResult(full: fullButton, compact: compactButton)
    }

    // MARK: - Private

    /// Создает яндекс пей контейнер кнопки
    private static func createYandexButton(
        locale: YandexPaySDKConfiguration.Locale
    ) throws -> IYandexPayButtonContainer {

        let config = YandexPaySDKConfiguration(
            environment: .sandbox,
            locale: locale
        )

        let initializer = YandexPayButtonContainerFactoryInitializer()
        let factory = try initializer.initializeButtonFactory(
            with: config,
            method: .fake(),
            flowAssembly: YandexPayPaymentFlowAssemblyMock()
        )
        let buttonConfig = YandexPayButtonContainerConfiguration(theme: .init(appearance: .dark))
        let buttonContainer = factory.createButtonContainer(
            with: buttonConfig,
            delegate: YandexPayButtonContainerDelegateMock()
        )

        return buttonContainer
    }

    private static func getSDK() throws -> (ui: AcquiringUISDK, core: AcquiringSdk) {
        let credential = AppSetting.shared.activeSdkCredentials
        let coreSDK = try SdkAssembly.assembleCoreSDK(credential: credential)
        let uiSDK = try SdkAssembly.assembleUISDK(credential: credential)
        return (uiSDK, coreSDK)
    }

    static func getYandexPayButtons(completion: @escaping (Result<ButtonsResult, Error>) -> Void) {
        let configuration = YandexPaySDKConfiguration(environment: .sandbox, locale: .system)
        guard let (uiSDK, _) = try? getSDK() else {
            completion(.failure(TestsError.basic))
            return
        }

        let delegateMock = YandexPayButtonContainerDelegateMock()

        uiSDK.yandexPayButtonContainerFactory(with: configuration) { result in
            switch result {
            case let .success(factory):
                let configuration = YandexPayButtonContainerConfiguration(
                    theme: YandexPayButtonContainerTheme(appearance: .dark)
                )
                let fullButton = factory.createButtonContainer(with: configuration, delegate: delegateMock)
                let compactButton = factory.createButtonContainer(with: configuration, delegate: delegateMock)
                fullButton.frame.size = CGSize(width: 326, height: 52)
                compactButton.frame.size = CGSize(width: 262, height: 52)
                completion(.success(ButtonsResult(full: fullButton, compact: compactButton)))
            case .failure:
                completion(.failure(TestsError.basic))
            }
        }
    }
}
