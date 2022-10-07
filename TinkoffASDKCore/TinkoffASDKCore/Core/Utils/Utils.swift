//
//  Utils.swift
//  TinkoffASDKCore
//
//  Copyright (c) 2020 Tinkoff Bank
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

import CommonCrypto
import Foundation
import Security

// MARK: JSON Conformance

public typealias JSONValue = Any

public typealias JSONObject = [String: JSONValue]

final class JSONSerializationFormat {
    public class func serialize(value: [String: JSONObject]) throws -> Data {
        return try JSONSerialization.data(withJSONObject: value, options: [.sortedKeys])
    }

    public class func deserialize(data: Data) throws -> JSONValue {
        return try JSONSerialization.jsonObject(with: data, options: [])
    }
}

public extension Encodable {
    func encode2JSONObject(dateEncodingStrategy: JSONEncoder.DateEncodingStrategy = .deferredToDate) throws -> JSONObject {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = dateEncodingStrategy

        let data = try encoder.encode(self)
        guard let dictionary = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any]
        else { throw NSError() }

        return dictionary
    }
}
