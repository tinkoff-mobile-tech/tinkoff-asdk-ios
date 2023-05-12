//
//
//  GetQRData.swift
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
public enum GetQRDataType: String, Encodable {
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

public struct GetQRData: Encodable {
    private enum CodingKeys: CodingKey {
        case paymentId
        case dataType

        var stringValue: String {
            switch self {
            case .paymentId: return Constants.Keys.paymentId
            case .dataType: return Constants.Keys.dataType
            }
        }
    }

    /// Уникальный идентификатор транзакции в системе Банка
    let paymentId: String
    /// Тип возвращаемых данных
    let dataType: GetQRDataType

    public init(paymentId: String, paymentInvoiceType: GetQRDataType = .url) {
        self.paymentId = paymentId
        dataType = paymentInvoiceType
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(paymentId, forKey: .paymentId)
        try container.encode(dataType.rawValue, forKey: .dataType)
    }
}
