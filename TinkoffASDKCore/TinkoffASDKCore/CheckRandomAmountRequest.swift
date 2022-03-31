//
//  CheckRandomAmountRequest.swift
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

import Foundation

public struct CheckingRandomAmountData: Codable {
    public var amount: Int
    public var requestKey: String

    public enum CodingKeys: String, CodingKey {
        case amount = "Amount"
        case requestKey = "RequestKey"
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        amount = try container.decode(Int.self, forKey: .amount)
        requestKey = try container.decode(String.self, forKey: .requestKey)
    }

    /// - Parameter amount: Сумма в копейках
    /// - Parameter requestKey: ключ операции для проверки
    public init(amount: Double, requestKey: String) {
        self.amount = Int(amount * 100)
        self.requestKey = requestKey
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(amount, forKey: .amount)
        try container.encode(requestKey, forKey: .requestKey)
    }
}

final class CheckRandomAmountRequest: RequestOperation, AcquiringRequestTokenParams {
    // MARK: RequestOperation

    public var name = "SubmitRandomAmount"

    public var parameters: JSONObject?

    // MARK: AcquiringRequestTokenParams

    ///
    /// отмечаем параметры которые участвуют в вычислении `token`
    public var tokenParamsKey: Set<String> = [CheckingRandomAmountData.CodingKeys.amount.rawValue,
                                              CheckingRandomAmountData.CodingKeys.requestKey.rawValue]

    ///
    /// - Parameter requestData: `CheckingRandomAmountData`
    public init(requestData: CheckingRandomAmountData) {
        if let json = try? requestData.encode2JSONObject() {
            parameters = json
        }
    }
}
