//
//
//  ThreeDSDeviceInfoProvider.swift
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
import class UIKit.UIScreen

public protocol IThreeDSDeviceInfoProvider {
    func createDeviceInfo(threeDSCompInd: String) -> ThreeDSDeviceInfo
}

public extension IThreeDSDeviceInfoProvider {
    var deviceInfo: ThreeDSDeviceInfo {
        createDeviceInfo(threeDSCompInd: "Y")
    }
}

/// Возвращает информацию для 3DS App Based SDK транзакции
public protocol IAppBasedSdkUiProvider {
    /// Тип интерфейса Native/HTML/Both через который пойдет транзакция
    func sdkInterface() -> TdsSdkInterface
    /// Тип ui-ая для проверки
    func sdkUiTypes() -> [TdsSdkUiType]
}

public struct AppBasedSdkUiProvider: IAppBasedSdkUiProvider {
    let prefferedInterface: TdsSdkInterface
    let prefferedUiTypes: [TdsSdkUiType]

    public init(prefferedInterface: TdsSdkInterface, prefferedUiTypes: [TdsSdkUiType]) {
        self.prefferedInterface = prefferedInterface
        self.prefferedUiTypes = prefferedUiTypes
    }

    public func sdkInterface() -> TdsSdkInterface {
        prefferedInterface
    }

    public func sdkUiTypes() -> [TdsSdkUiType] {
        prefferedUiTypes
    }
}

final class ThreeDSDeviceInfoProvider: IThreeDSDeviceInfoProvider {
    private let languageProvider: ILanguageProvider
    private let urlBuilder: IThreeDSURLBuilder
    private let sdkUiProvider: IAppBasedSdkUiProvider

    init(
        languageProvider: ILanguageProvider,
        urlBuilder: IThreeDSURLBuilder,
        sdkUiProvider: IAppBasedSdkUiProvider
    ) {
        self.languageProvider = languageProvider
        self.urlBuilder = urlBuilder
        self.sdkUiProvider = sdkUiProvider
    }

    func createDeviceInfo(threeDSCompInd: String) -> ThreeDSDeviceInfo {
        ThreeDSDeviceInfo(
            // BRW
            threeDSCompInd: threeDSCompInd,
            javaEnabled: "true",
            colorDepth: 32,
            language: (languageProvider.language ?? .ru).rawValue,
            timezone: TimeZone.current.secondsFromGMT() / 60,
            screenHeight: Int(UIScreen.main.bounds.height * UIScreen.main.scale),
            screenWidth: Int(UIScreen.main.bounds.width * UIScreen.main.scale),
            cresCallbackUrl: urlBuilder.url(ofType: .confirmation3DSTerminationV2URL).absoluteString,
            // SDK
            sdkAppID: nil,
            sdkEphemPubKey: nil,
            sdkReferenceNumber: nil,
            sdkTransID: nil,
            sdkMaxTimeout: nil,
            sdkEncData: nil,
            sdkInterface: sdkUiProvider.sdkInterface(),
            sdkUiType: sdkUiProvider.sdkUiTypes().map { $0.rawValue }.joined(separator: ",")
        )
    }
}
