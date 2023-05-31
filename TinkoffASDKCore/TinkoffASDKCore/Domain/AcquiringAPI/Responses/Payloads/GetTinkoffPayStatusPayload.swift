//
//
//  GetTinkoffPayStatusPayload.swift
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

public struct GetTinkoffPayStatusPayload {
    public enum Status {
        case disallowed
        case allowed(TinkoffPayMethod)
    }

    public let status: Status

    public init(status: Status) {
        self.status = status
    }
}

// MARK: - GetTinkoffPayStatusPayload + Decodable

extension GetTinkoffPayStatusPayload: Decodable {
    private enum CodingKeys: CodingKey {
        case status

        var stringValue: String {
            switch self {
            case .status: return Constants.Keys.params
            }
        }
    }
}

// MARK: - GetTinkoffPayStatusPayload.Status + Decodable

extension GetTinkoffPayStatusPayload.Status: Decodable {
    private enum CodingKeys: String, CodingKey {
        case isAllowed = "Allowed"
        case version = "Version"
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let isAllowed = try container.decode(Bool.self, forKey: .isAllowed)

        if isAllowed {
            self = .allowed(try TinkoffPayMethod(from: decoder))
        } else {
            self = .disallowed
        }
    }
}
