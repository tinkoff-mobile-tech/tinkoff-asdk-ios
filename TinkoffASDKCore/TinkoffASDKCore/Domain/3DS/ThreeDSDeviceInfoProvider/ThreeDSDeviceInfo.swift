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

public struct ThreeDSDeviceInfo {
    public let threeDSCompInd: String
    public let javaEnabled: String
    public let colorDepth: Int
    public let language: String
    public let timezone: Int
    public let screenHeight: Int
    public let screenWidth: Int
    public let cresCallbackUrl: String
    public let sdkAppID: String?
    public let sdkEphemPubKey: String?
    public let sdkReferenceNumber: String?
    public let sdkTransID: String?
    public let sdkMaxTimeout: String?
    public let sdkEncData: String?
    public let sdkInterface: String
    public let sdkUiType: String

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
