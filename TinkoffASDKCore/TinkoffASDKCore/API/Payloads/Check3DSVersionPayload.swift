//
//
//  Check3DSVersionPayload.swift
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

public struct Check3DSVersionPayload: Decodable, Equatable {
    public let version: String
    public let tdsServerTransID: String?
    public let threeDSMethodURL: String?
    
    private enum CodingKeys: CodingKey {
        case version
        case tdsServerTransID
        case threeDSMethodURL
        
        var stringValue: String {
            switch self {
            case .version: return APIConstants.Keys.version
            case .tdsServerTransID: return APIConstants.Keys.tdsServerTransID
            case .threeDSMethodURL: return APIConstants.Keys.threeDSMethodURL
            }
        }
    }
    
    public init(version: String,
                tdsServerTransID: String?,
                threeDSMethodURL: String?) {
        self.version = version
        self.tdsServerTransID = tdsServerTransID
        self.threeDSMethodURL = threeDSMethodURL
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        version = try container.decode(String.self, forKey: .version)
        tdsServerTransID = try container.decodeIfPresent(String.self, forKey: .tdsServerTransID)
        threeDSMethodURL = try container.decodeIfPresent(String.self, forKey: .threeDSMethodURL)
    }
}
