//
//
//  ThreeDSDeviceInfo.swift
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

@available(*, deprecated, renamed: "ThreeDSDeviceInfo")
public typealias DeviceInfoParams = ThreeDSDeviceInfo

public struct ThreeDSDeviceInfo {
    let threeDSCompInd: String
    let javaEnabled: String
    let colorDepth: Int
    let language: String
    let timezone: Int
    let screenHeight: Int
    let screenWidth: Int
    let cresCallbackUrl: String
    let sdkAppID: String?
    let sdkEphemPubKey: String?
    let sdkReferenceNumber: String?
    let sdkTransID: String?
    let sdkMaxTimeout: String?
    let sdkEncData: String?
    let sdkInterface: String
    let sdkUiType: String

    public init(
        threeDSCompInd: String = "Y",
        cresCallbackUrl: String,
        languageId: String = "ru",
        screenWidth: Int,
        screenHeight: Int,
        colorDepth: Int = 32,
        sdkAppID: String? = nil,
        sdkEphemPubKey: String? = nil,
        sdkReferenceNumber: String? = nil,
        sdkTransID: String? = nil,
        sdkMaxTimeout: String? = nil,
        sdkEncData: String? = nil
    ) {
        self.threeDSCompInd = threeDSCompInd
        javaEnabled = "true"
        self.colorDepth = colorDepth
        language = languageId
        timezone = TimeZone.current.secondsFromGMT() / 60
        self.screenHeight = screenHeight
        self.screenWidth = screenWidth
        self.cresCallbackUrl = cresCallbackUrl
        self.sdkAppID = sdkAppID
        self.sdkEphemPubKey = sdkEphemPubKey
        self.sdkReferenceNumber = sdkReferenceNumber
        self.sdkTransID = sdkTransID
        self.sdkMaxTimeout = sdkMaxTimeout
        self.sdkEncData = sdkEncData
        sdkInterface = "03"
        sdkUiType = "01,02,03,04,05"
    }
}

// MARK: - ThreeDSDeviceInfo + Encodable

extension ThreeDSDeviceInfo: Encodable {
    private enum CodingKeys: String, CodingKey {
        case threeDSCompInd
        case javaEnabled
        case colorDepth
        case language
        case timezone
        case screenHeight = "screen_height"
        case screenWidth = "screen_width"
        case cresCallbackUrl
        case sdkAppID
        case sdkEphemPubKey
        case sdkReferenceNumber
        case sdkTransID
        case sdkMaxTimeout
        case sdkEncData
        case sdkInterface
        case sdkUiType
    }
}
