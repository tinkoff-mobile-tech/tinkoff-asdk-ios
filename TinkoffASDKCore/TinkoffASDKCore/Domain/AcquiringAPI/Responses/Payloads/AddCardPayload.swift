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

/// Данные, полученные в методе `AddCard`
public struct AddCardPayload: Equatable {
    /// Идентификатор запроса при привязке карты
    public let requestKey: String
    /// Идентификатор платежа при проверке карты.
    ///
    /// Обязателен при переданном параметре `checkType` == `3DS`/`3DSHOLD`/`HOLD`
    public let paymentId: String?

    public init(requestKey: String, paymentId: String? = nil) {
        self.requestKey = requestKey
        self.paymentId = paymentId
    }
}

// MARK: - AddCardPayload + Decodable

extension AddCardPayload: Decodable {
    private enum CodingKeys: CodingKey {
        case requestKey
        case paymentId

        var stringValue: String {
            switch self {
            case .requestKey: return Constants.Keys.requestKey
            case .paymentId: return Constants.Keys.paymentId
            }
        }
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        requestKey = try container.decode(String.self, forKey: .requestKey)
        paymentId = try container
            .decodeIfPresent(Int64.self, forKey: .paymentId)
            .map(String.init)
    }
}
