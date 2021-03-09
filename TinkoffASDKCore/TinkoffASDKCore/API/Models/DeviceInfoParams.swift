//
//
//  DeviceInfoParams.swift
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

public struct DeviceInfoParams: Codable {
    var threeDSCompInd: String
    var javaEnabled: String
    var colorDepth: Int
    var language: String
    var timezone: Int
    var screenHeight: Int
    var screenWidth: Int
    var cresCallbackUrl: String

    enum CodingKeys: String, CodingKey {
        case threeDSCompInd
        case javaEnabled
        case colorDepth
        case language
        case timezone
        case screenHeight = "screen_height"
        case screenWidth = "screen_width"
        case cresCallbackUrl
    }

    public init(cresCallbackUrl: String, languageId: String = "ru", screenWidth: Int, screenHeight: Int, colorDepth: Int = 32) {
        threeDSCompInd = "Y"
        javaEnabled = "true"
        self.colorDepth = colorDepth
        language = languageId
        timezone = TimeZone.current.secondsFromGMT() / 60
        self.screenHeight = screenHeight
        self.screenWidth = screenWidth
        self.cresCallbackUrl = cresCallbackUrl
    }
}
