//
//
//  InitPayload.swift
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

public struct InitPayload: Decodable, Equatable {
    private enum CodingKeys: CodingKey {
        case amount
        case orderId
        case paymentId
        case status

        var stringValue: String {
            switch self {
            case .amount: return Constants.Keys.amount
            case .orderId: return Constants.Keys.orderId
            case .paymentId: return Constants.Keys.paymentId
            case .status: return Constants.Keys.status
            }
        }
    }

    public let amount: Int64
    public let orderId: String
    public let paymentId: String
    public let status: AcquiringStatus

    public init(
        amount: Int64,
        orderId: String,
        paymentId: String,
        status: AcquiringStatus
    ) {
        self.amount = amount
        self.orderId = orderId
        self.paymentId = paymentId
        self.status = status
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        paymentId = try container.decode(String.self, forKey: .paymentId)
        amount = try container.decode(Int64.self, forKey: .amount)
        orderId = try container.decode(String.self, forKey: .orderId)
        status = try container.decodeIfPresent(AcquiringStatus.self, forKey: .status) ?? .unknown
    }
}
