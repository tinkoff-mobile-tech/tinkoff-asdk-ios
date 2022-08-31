//
//
//  PaymentInvoiceQRCodeData.swift
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

/// Тип возвращаемых данных для генерации QR-кода
public enum PaymentInvoiceSBPSourceType: String, Codable {
    /// `IMAGE` – В ответе возвращается SVG изображение QR-кода
    case imageSVG = "IMAGE"

    /// `PAYLOAD` – В ответе возвращается url с параметрами  (по-умолчанию)
    case url = "PAYLOAD"

    public init(rawValue: String) {
        switch rawValue {
        case "IMAGE": self = .imageSVG
        default: self = .url
        }
    }
}

public struct PaymentInvoiceQRCodeData: Codable {
    ///
    /// Уникальный идентификатор транзакции в системе Банка
    var paymentId: PaymentId

    ///
    /// Тип возвращаемых данных
    var paymentInvoiceType: PaymentInvoiceSBPSourceType

    enum CodingKeys: String, CodingKey {
        case paymentId = "PaymentId"
        case paymentInvoiceType = "DataType"
    }

    public init(paymentId: PaymentId, paymentInvoiceType: PaymentInvoiceSBPSourceType = .url) {
        self.paymentId = paymentId
        self.paymentInvoiceType = paymentInvoiceType
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if let typeValue = try? container.decode(String.self, forKey: .paymentInvoiceType) {
            paymentInvoiceType = PaymentInvoiceSBPSourceType(rawValue: typeValue)
        } else {
            paymentInvoiceType = .url
        }
        if let paymentId = try? container.decode(PaymentId.self, forKey: .paymentId) {
            self.paymentId = paymentId
        } else {
            let paymentIdNumber = try container.decode(Int64.self, forKey: .paymentId)
            self.paymentId = String(paymentIdNumber)
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(paymentId, forKey: .paymentId)
        try container.encode(paymentInvoiceType.rawValue, forKey: .paymentInvoiceType)
    }
}
