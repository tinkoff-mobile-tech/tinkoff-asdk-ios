//
//
//  Confirmation3DSData.swift
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

public struct Confirmation3DSData: Codable {
    var acsUrl: String
    var pareq: String
    var md: String

    enum CodingKeys: String, CodingKey {
        case acsUrl = "ACSUrl"
        case pareq = "PaReq"
        case md = "MD"
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        acsUrl = try container.decode(String.self, forKey: .acsUrl)
        pareq = try container.decode(String.self, forKey: .pareq)
        md = try container.decode(String.self, forKey: .md)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(acsUrl, forKey: .acsUrl)
        try container.encode(pareq, forKey: .pareq)
        try container.encode(md, forKey: .md)
    }
}
