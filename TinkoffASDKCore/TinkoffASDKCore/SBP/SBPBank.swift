//
//
//  SBPBank.swift
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

public struct SBPBank: Decodable {
    public let name: String
    public let logoURL: URL
    public let schema: String
    
    enum CodingKeys: String, CodingKey {
        case name = "bankName"
        case logoURL
        case schema
    }
    
//    public init(from decoder: Decoder) throws {
//        let container = try decoder.container(keyedBy: CodingKeys.self)
////        static let win1251 = String.Encoding(rawValue: CFStringConvertEncodingToNSStringEncoding(CFStringEncoding(CFStringEncodings.windowsCyrillic.rawValue)))
//        let wrongCodingName = try container.decode(String.self, forKey: .name)
//        let nameData = wrongCodingName.data(using: .windowsCP1251) ?? Data()
//        name = String(data: nameData, encoding: .utf8) ?? ""
//        
//        logoURL = try container.decode(URL.self, forKey: .logoURL)
//        schema = try container.decode(String.self, forKey: .schema)
//    }
}
