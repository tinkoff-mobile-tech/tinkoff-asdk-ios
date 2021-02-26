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
    public let amount: Int64
    public let orderId: String
    public let paymentId: Int64
    public let status: PaymentStatus
    
    private enum CodingKeys: CodingKey {
        case amount
        case orderId
        case paymentId
        case status
        
        var stringValue: String {
            switch self {
            case .amount: return APIConstants.Keys.amount
            case .orderId: return APIConstants.Keys.orderId
            case .paymentId: return APIConstants.Keys.paymentId
            case .status: return APIConstants.Keys.status
            }
        }
    }

    public init(amount: Int64,
                orderId: String,
                paymentId: Int64,
                status: PaymentStatus) {
        self.amount = amount
        self.orderId = orderId
        self.paymentId = paymentId
        self.status = status
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        amount = try container.decode(Int64.self, forKey: .amount)
        orderId = try container.decode(String.self, forKey: .orderId)
        status = try container.decodeIfPresent(PaymentStatus.self, forKey: .status) ?? .unknown
        
        /// В доке API тип у `paymentId` указан как `number`, но по итогу почему-то приходит как `String`
        if let stringPaymentId = try? container.decode(String.self, forKey: .paymentId),
           let paymentId = Int64(stringPaymentId) {
            self.paymentId = paymentId
        } else {
            paymentId = try container.decode(Int64.self, forKey: .paymentId)
        }
    }
}
