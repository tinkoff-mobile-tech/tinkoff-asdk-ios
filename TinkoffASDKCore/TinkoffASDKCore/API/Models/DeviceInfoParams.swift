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

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        threeDSCompInd = try container.decode(String.self, forKey: .threeDSCompInd)
        javaEnabled = try container.decode(String.self, forKey: .javaEnabled)
        colorDepth = try container.decode(Int.self, forKey: .colorDepth)
        language = try container.decode(String.self, forKey: .language)
        timezone = try container.decode(Int.self, forKey: .timezone)
        screenHeight = try container.decode(Int.self, forKey: .screenHeight)
        screenWidth = try container.decode(Int.self, forKey: .screenWidth)
        cresCallbackUrl = try container.decode(String.self, forKey: .cresCallbackUrl)
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

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(threeDSCompInd, forKey: .threeDSCompInd)
        try container.encode(javaEnabled, forKey: .javaEnabled)
        try container.encode(colorDepth, forKey: .colorDepth)
        try container.encode(language, forKey: .language)
        try container.encode(timezone, forKey: .timezone)
        try container.encode(screenHeight, forKey: .screenHeight)
        try container.encode(screenWidth, forKey: .screenWidth)
        try container.encode(cresCallbackUrl, forKey: .cresCallbackUrl)
    }
}
