//
//
//  SdkAssembly.swift
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

import Foundation
import TinkoffASDKCore
import TinkoffASDKUI

struct SdkAssembly {
    static func assembleUISDK(credential: SdkCredentials) throws -> AcquiringUISDK {
        let coreConfiguration = createCoreConfiguration(credential: credential)
        let uiConfiguration = UISDKConfiguration(addCardCheckType: AppSetting.shared.addCardChekType)

        return try AcquiringUISDK(
            coreSDKConfiguration: coreConfiguration,
            uiSDKConfiguration: uiConfiguration
        )
    }

    static func assembleCoreSDK(credential: SdkCredentials) throws -> AcquiringSdk {
        try AcquiringSdk(configuration: createCoreConfiguration(credential: credential))
    }

    private static func createCoreConfiguration(credential: SdkCredentials) -> AcquiringSdkConfiguration {
        let sdkCredential = AcquiringSdkCredential(
            terminalKey: credential.terminalKey,
            publicKey: credential.publicKey
        )

        let tokenProvider = SampleTokenProvider(password: credential.terminalPassword)

        let acquiringSDKConfiguration = AcquiringSdkConfiguration(
            credential: sdkCredential,
            server: assembleServer(),
            logger: Logger(), // для включения логирования, заменить nil на Logger()
            tokenProvider: tokenProvider,
            appBasedSdkInterface: AppSetting.shared.appBasedSdkInterface
        )

        return acquiringSDKConfiguration
    }

    private static func assembleServer() -> AcquiringSdkEnvironment {
        if ProcessInfo.processInfo.environment[.UITests] != nil {
            if let mockUrl = ProcessInfo.processInfo.environment[.mockServerUrl] {
                return AcquiringSdkEnvironment.custom(mockUrl)
            }
        }
        return AppSetting.shared.serverType
    }
}

// MARK: - Constants

private extension String {
    static let UITests = "UI_TESTS"
    static let mockServerUrl = "MOCK_SERVER_URL"
}
