//
//
//  APIResponse.swift
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

struct APIResponse<Model: Decodable>: Decodable {
    private enum CodingKeys: CodingKey {
        case success
        case terminalKey
        case errorCode

        var stringValue: String {
            switch self {
            case .success: return Constants.Keys.success
            case .terminalKey: return Constants.Keys.terminalKey
            case .errorCode: return Constants.Keys.errorCode
            }
        }
    }

    let success: Bool
    let errorCode: Int
    let terminalKey: String?
    let result: Swift.Result<Model, APIFailureError>

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        terminalKey = try container.decodeIfPresent(String.self, forKey: .terminalKey)
        success = try container.decode(Bool.self, forKey: .success)
        let errorCodeString = try container.decode(String.self, forKey: .errorCode)
        errorCode = Int(errorCodeString) ?? 0
        result = errorCode == 0
            ? .success(try Model(from: decoder))
            : .failure(try APIFailureError(from: decoder))
    }

    init(
        success: Bool,
        errorCode: Int,
        terminalKey: String?,
        result: Swift.Result<Model, APIFailureError>
    ) {
        self.success = success
        self.terminalKey = terminalKey
        self.result = result
        self.errorCode = errorCode
    }
}
