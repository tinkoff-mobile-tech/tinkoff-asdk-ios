//
//
//  AddCardPayload.swift
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

public struct AddCardPayload: Decodable, Equatable {
    private enum CodingKeys: CodingKey {
        case requestKey

        var stringValue: String {
            switch self {
            case .requestKey: return APIConstants.Keys.requestKey
            }
        }
    }

    public let requestKey: String

    public init(requestKey: String) {
        self.requestKey = requestKey
    }
}
