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

final class ThreeDSDeviceInfoProvider: IThreeDSDeviceInfoProvider {
    private let languageProvider: ILanguageProvider
    private let urlBuilder: IThreeDSURLBuilder

    init(
        languageProvider: ILanguageProvider,
        urlBuilder: IThreeDSURLBuilder
    ) {
        self.languageProvider = languageProvider
        self.urlBuilder = urlBuilder
    }

    func createDeviceInfo(threeDSCompInd: String) -> ThreeDSDeviceInfo {
        ThreeDSDeviceInfo(
            threeDSCompInd: threeDSCompInd,
            cresCallbackUrl: urlBuilder.url(ofType: .confirmation3DSTerminationV2URL).absoluteString,
            languageId: (languageProvider.language ?? .ru).rawValue,
            screenWidth: Int(UIScreen.main.bounds.width * UIScreen.main.scale),
            screenHeight: Int(UIScreen.main.bounds.height * UIScreen.main.scale)
        )
    }
}
