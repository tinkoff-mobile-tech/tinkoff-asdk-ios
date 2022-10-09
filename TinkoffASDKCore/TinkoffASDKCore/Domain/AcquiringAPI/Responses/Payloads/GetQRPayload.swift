//
//
//  GetQRPayload.swift
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

public struct GetQRPayload: Decodable {
    private enum CodingKeys: CodingKey {
        case qrCodeData
        case orderId
        case paymentId

        var stringValue: String {
            switch self {
            case .qrCodeData: return Constants.Keys.qrCodeData
            case .orderId: return Constants.Keys.orderId
            case .paymentId: return Constants.Keys.paymentId
            }
        }
    }

    public let qrCodeData: String
    public let orderId: String
    public let paymentId: String

    public init(
        qrCodeData: String,
        orderId: String,
        paymentId: String
    ) {
        self.qrCodeData = qrCodeData
        self.orderId = orderId
        self.paymentId = paymentId
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        qrCodeData = try container.decode(String.self, forKey: .qrCodeData)
        orderId = try container.decode(String.self, forKey: .orderId)

        if let paymentId = try? container.decode(String.self, forKey: .paymentId) {
            self.paymentId = paymentId
        } else {
            paymentId = String(try container.decode(Int64.self, forKey: .paymentId))
        }
    }
}
