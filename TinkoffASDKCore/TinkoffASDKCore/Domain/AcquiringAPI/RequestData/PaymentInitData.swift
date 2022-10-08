//
//
//  PaymentInitData.swift
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

/// Инициализация платежа, подробнее: [Init - создание заказа на оплату](https://oplata.tinkoff.ru/develop/api/payments/init-request/)
public struct PaymentInitData: Encodable {
    private enum CodingKeys: CodingKey {
        case amount
        case orderId
        case customerKey
        case description
        case payType
        case savingAsParentPayment
        case paymentFormData
        case receipt
        case shops
        case receipts
        case redirectDueDate
        case successURL
        case failURL

        var stringValue: String {
            switch self {
            case .amount: return Constants.Keys.amount
            case .orderId: return Constants.Keys.orderId
            case .customerKey: return Constants.Keys.customerKey
            case .description: return Constants.Keys.description
            case .payType: return Constants.Keys.payType
            case .savingAsParentPayment: return Constants.Keys.savingAsParentPayment
            case .paymentFormData: return Constants.Keys.data
            case .receipt: return Constants.Keys.receipt
            case .shops: return Constants.Keys.shops
            case .receipts: return Constants.Keys.receipts
            case .redirectDueDate: return Constants.Keys.redirectDueDate
            case .successURL: return Constants.Keys.successURL
            case .failURL: return Constants.Keys.failURL
            }
        }
    }

    /// Сумма в копейках. Например, сумма 3руб. 12коп. это число `312`.
    /// Параметр должен быть равен сумме всех товаров в чеке (параметров "Amount", переданных в объекте Items)
    public var amount: Int64

    /// Номер заказа в системе Продавца
    public var orderId: String

    /// Идентификатор клиента в системе продавца. Например, для этого идентификатора будут сохраняться список карт.
    public var customerKey: String?

    /// Краткое описание
    public var description: String?

    /// Тип проведения платежа
    public var payType: PayType?

    /// Если передается и установлен в `true`, то регистрирует платёж как рекуррентный (родительский). В этом случае после оплаты в нотификации на `AUTHORIZED` будет передан параметр `RebillId` который можно использовать в методе [Charge](https://oplata.tinkoff.ru/landing/develop/documentation/auto_Charge).
    public var savingAsParentPayment: Bool?

    /// `JSON` объект, содержащий дополнительные параметры в виде `[Key: Value]`.
    /// `Key: String` – 20 знаков,
    /// `Value: String` – 100 знаков.
    /// Максимальное количество пар параметров не может превышать 20.
    public var paymentFormData: [String: String]?

    /// Данные чека
    public var receipt: Receipt?

    /// Данные маркетплейса. Используется для разбивки платежа по партнерам.
    public var shops: [Shop]?
    /// Чеки для каждого `Shop` из объекта `PaymentInitData.shops`. В каждом чеке нужно указывать `Receipt.shopCode` == `Shop.shopCode`
    public var receipts: [Receipt]?
    /// Cрок жизни ссылки.
    public var redirectDueDate: Date?
    /// Страница успеха
    public var successURL: String?
    /// Страница ошибки
    public var failURL: String?

    public init(
        amount: Int64,
        orderId: String,
        customerKey: String?,
        redirectDueDate: Date? = nil,
        payType: PayType? = nil,
        successURL: String? = nil,
        failURL: String? = nil
    ) {
        self.amount = amount
        self.orderId = orderId
        self.customerKey = customerKey
        self.redirectDueDate = redirectDueDate
        self.payType = payType
        self.successURL = successURL
        self.failURL = failURL
    }

    public init(
        amount: NSDecimalNumber,
        orderId: String,
        customerKey: String?,
        redirectDueDate: Date? = nil,
        payType: PayType? = nil,
        successURL: String? = nil,
        failURL: String? = nil
    ) {
        let int64Amount = Int64(amount.doubleValue * 100)
        self.init(
            amount: int64Amount,
            orderId: orderId,
            customerKey: customerKey,
            redirectDueDate: redirectDueDate,
            payType: payType,
            successURL: successURL,
            failURL: failURL
        )
    }

    public mutating func addPaymentData(_ additionalData: [String: String]) {
        var updatedData: [String: String] = [:]

        paymentFormData?.forEach { item in
            updatedData.updateValue(item.value, forKey: item.key)
        }

        additionalData.forEach { item in
            updatedData.updateValue(item.value, forKey: item.key)
        }

        paymentFormData = updatedData
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(amount, forKey: .amount)
        try container.encode(orderId, forKey: .orderId)
        try container.encodeIfPresent(customerKey, forKey: .customerKey)
        try container.encodeIfPresent(payType?.rawValue, forKey: .payType)
        if description != nil { try? container.encode(description, forKey: .description) }
        if redirectDueDate != nil { try? container.encode(redirectDueDate, forKey: .redirectDueDate) }
        if let value = savingAsParentPayment, value == true { try container.encode("Y", forKey: .savingAsParentPayment) }
        if receipt != nil { try? container.encode(receipt, forKey: .receipt) }
        if shops != nil { try? container.encode(shops, forKey: .shops) }
        if receipts != nil { try? container.encode(receipts, forKey: .receipts) }
        if paymentFormData != nil { try? container.encode(paymentFormData, forKey: .paymentFormData) }
        if successURL != nil { try? container.encode(successURL, forKey: .successURL) }
        if failURL != nil { try? container.encode(failURL, forKey: .failURL) }
    }
}
