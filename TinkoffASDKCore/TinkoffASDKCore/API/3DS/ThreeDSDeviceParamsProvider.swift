//
//
//  ThreeDSDeviceParamsProvider.swift
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

public protocol ThreeDSDeviceParamsProvider {
    var deviceInfoParams: DeviceInfoParams { get }
}

struct DefaultThreeDSDeviceParamsProvider: ThreeDSDeviceParamsProvider {
    private let screenSize: CGSize
    private let language: AcquiringSdkLanguage
    private let threeDSURLBuilder: ThreeDSURLBuilder
    
    init(screenSize: CGSize,
         language: AcquiringSdkLanguage,
         threeDSURLBuilder: ThreeDSURLBuilder) {
        self.screenSize = screenSize
        self.language = language
        self.threeDSURLBuilder = threeDSURLBuilder
    }
    
    var deviceInfoParams: DeviceInfoParams {
        // TODO: Log error
        let cresCallbackUrl = (try? threeDSURLBuilder.buildURL(type: .confirmation3DSTerminationV2URL).absoluteString) ?? ""
        
        return DeviceInfoParams(cresCallbackUrl: cresCallbackUrl,
                                languageId: language.rawValue,
                                screenWidth: Int(screenSize.width),
                                screenHeight: Int(screenSize.height))
    }
}
