//
//
//  PaymentSourceData.swift
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

/// Источинк оплаты
public enum PaymentSourceData: Codable {
    /// при оплате по реквизитам  карты
    ///
    /// - Parameters:
    ///   - number: номер карты в виде строки
    ///   - expDate: expiration date в виде строки `MMYY`
    ///   - cvv: код `CVV` в виде строки.
    case cardNumber(number: String, expDate: String, cvv: String)

    /// при оплате с ранее сохраненной карты
    ///
    /// - Parameters:
    ///   - cardId: идентификатор сохраненной карты
    ///   - cvv: код `CVV` в виде строки.
    case savedCard(cardId: String, cvv: String?)

    /// при оплате на основе родительского платежа
    ///
    /// - Parameters:
    ///   - rebuidId: идентификатор родительского платежа
    case parentPayment(rebillId: String)

    /// при оплате с помощью **ApplePay**
    ///
    /// - Parameters:
    ///   - string: UTF-8 encoded JSON dictionary of encrypted payment data from `PKPaymentToken.paymentData`
    case paymentData(String)

    case unknown

    enum CodingKeys: String, CodingKey {
        case cardNumber = "PAN"
        case cardExpDate = "ExpDate"
        case cardCVV = "CVV"
        case savedCardId = "CardId"
        case paymentData = "PaymentData"
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self = .unknown

        if let number = try? container.decode(String.self, forKey: .cardNumber),
           let expDate = try? container.decode(String.self, forKey: .cardExpDate),
           let cvv = try? container.decode(String.self, forKey: .cardCVV)
        {
            self = .cardNumber(number: number, expDate: expDate, cvv: cvv)
        } else if let cardId = try? container.decode(String.self, forKey: .savedCardId) {
            let cvv = try? container.decode(String.self, forKey: .cardCVV)
            self = .savedCard(cardId: cardId, cvv: cvv)
        } else if let paymentDataString = try? container.decode(String.self, forKey: .paymentData) {
            self = .paymentData(paymentDataString)
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case let .cardNumber(number, expData, cvv):
            try container.encode(number, forKey: .cardNumber)
            try container.encode(expData, forKey: .cardExpDate)
            try container.encode(cvv, forKey: .cardCVV)

        case let .savedCard(cardId, cvv):
            try container.encode(cardId, forKey: .savedCardId)
            try container.encode(cvv, forKey: .cardCVV)

        case let .paymentData(data):
            try container.encode(data, forKey: .paymentData)

        default:
            break
        }
    }
}
