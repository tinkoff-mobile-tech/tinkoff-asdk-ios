//
//
//  DefaultThreeDSDeviceParamsProvider.swift
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

import struct CoreGraphics.CGSize
import Foundation

public protocol ThreeDSDeviceParamsProvider {
    var deviceInfoParams: DeviceInfoParams { get }
}

final class DefaultThreeDSDeviceParamsProvider: ThreeDSDeviceParamsProvider {
    var deviceInfoParams: DeviceInfoParams {
        DeviceInfoParams(
            cresCallbackUrl: urlBuilder.url(ofType: .confirmation3DSTerminationV2URL).absoluteString,
            languageId: (languageProvider.language ?? .ru).rawValue,
            screenWidth: Int(screenSize.width),
            screenHeight: Int(screenSize.height)
        )
    }

    private let screenSize: CGSize
    private let languageProvider: ILanguageProvider
    private let urlBuilder: IThreeDSURLBuilder

    init(
        screenSize: CGSize,
        languageProvider: ILanguageProvider,
        urlBuilder: IThreeDSURLBuilder
    ) {
        self.screenSize = screenSize
        self.languageProvider = languageProvider
        self.urlBuilder = urlBuilder
    }
}
