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

import TinkoffASDKCore
import TinkoffASDKUI

struct SdkAssembly {

    static func assembleUIsdk(
        creds: SdkCredentials,
        style: Style = DefaultStyle()
    ) throws -> AcquiringUISDK {

        let credentional = AcquiringSdkCredential(
            terminalKey: creds.terminalKey,
            publicKey: creds.publicKey
        )

        let tokenProvider = SampleTokenProvider()
        let logger = AcquiringLoggerDefault()

        let acquiringSDKConfiguration = AcquiringSdkConfiguration(credential: credentional, tokenProvider: tokenProvider)
        acquiringSDKConfiguration.logger = logger

        return try AcquiringUISDK(configuration: acquiringSDKConfiguration, style: style)
    }
}
