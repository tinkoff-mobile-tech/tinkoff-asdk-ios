//
//
//  ChargePaymentPayload.swift
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

public struct ChargePaymentPayload: Decodable {
    public var orderId: String
    public var paymentId: PaymentId
    public var amount: NSDecimalNumber
    public let status: PaymentStatus
    public let paymentState: GetPaymentStatePayload
    
    private enum CodingKeys: String, CodingKey {
        case orderId = "OrderId"
        case paymentId = "PaymentId"
        case amount = "Amount"
        case status = "Status"
    }
    
    public init(orderId: String,
                paymentId: PaymentId,
                amount: Int64,
                status: PaymentStatus,
                paymentState: GetPaymentStatePayload)
    {
        self.orderId = orderId
        self.paymentId = paymentId
        self.amount = NSDecimalNumber(value: Double(amount) / 100)
        self.status = status
        self.paymentState = paymentState
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        paymentState = try GetPaymentStatePayload(from: decoder)
        status = paymentState.status
        orderId = try container.decode(String.self, forKey: .orderId)
        paymentId = try container.decode(String.self, forKey: .paymentId)

        let value = try container.decode(Int64.self, forKey: .amount)
        amount = NSDecimalNumber(value: Double(value) / 100)

    }
}
