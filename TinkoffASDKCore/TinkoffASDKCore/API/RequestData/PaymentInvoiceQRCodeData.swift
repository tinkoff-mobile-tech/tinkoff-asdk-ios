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
    enum CodingKeys: CodingKey {
        case paymentId
        case paymentInvoiceType

        var stringValue: String {
            switch self {
            case .paymentId: return APIConstants.Keys.paymentId
            case .paymentInvoiceType: return APIConstants.Keys.dataType
            }
        }
    }

    /// Уникальный идентификатор транзакции в системе Банка
    let paymentId: String
    /// Тип возвращаемых данных
    let paymentInvoiceType: PaymentInvoiceSBPSourceType

    public init(paymentId: String, paymentInvoiceType: PaymentInvoiceSBPSourceType = .url) {
        self.paymentId = paymentId
        self.paymentInvoiceType = paymentInvoiceType
    }

    @available(*, deprecated, message: "Use `init(paymentId, paymentInvoiceType)` with string `paymentId` instead")
    public init(paymentId: Int64, paymentInvoiceType: PaymentInvoiceSBPSourceType = .url) {
        self.paymentId = String(paymentId)
        self.paymentInvoiceType = paymentInvoiceType
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if let typeValue = try? container.decode(String.self, forKey: .paymentInvoiceType) {
            paymentInvoiceType = PaymentInvoiceSBPSourceType(rawValue: typeValue)
        } else {
            paymentInvoiceType = .url
        }
        if let paymentId = try? container.decode(String.self, forKey: .paymentId) {
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
