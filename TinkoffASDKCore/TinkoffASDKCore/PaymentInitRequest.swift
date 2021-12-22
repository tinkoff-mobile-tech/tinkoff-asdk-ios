//
//  PaymentInitRequest.swift
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

/// Инициализация платежа, подробнее: [Init - создание заказа на оплату](https://oplata.tinkoff.ru/develop/api/payments/init-request/)
public struct PaymentInitData: Codable {
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

    enum CodingKeys: String, CodingKey {
        case amount = "Amount"
        case orderId = "OrderId"
        case customerKey = "CustomerKey"
        case description = "Description"
        case payType = "PayType"
        case savingAsParentPayment = "Recurrent"
        case paymentFormData = "DATA"
        case receipt = "Receipt"
        case shops = "Shops"
        case receipts = "Receipts"
        case redirectDueDate = "RedirectDueDate"
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        amount = try container.decode(Int64.self, forKey: .amount)
        orderId = try container.decode(String.self, forKey: .orderId)
        customerKey = try container.decodeIfPresent(String.self, forKey: .customerKey)
        description = try? container.decode(String.self, forKey: .description)
        redirectDueDate = try? container.decode(Date.self, forKey: .redirectDueDate)

        if let payTypeValue = try? container.decode(String.self, forKey: .payType) {
            payType = PayType(rawValue: payTypeValue)
        }

        if let value = try? container.decode(String.self, forKey: .savingAsParentPayment), value.uppercased() == "Y" {
            savingAsParentPayment = true
        }

        paymentFormData = try? container.decode([String: String].self, forKey: .paymentFormData)
        receipt = try? container.decode(Receipt.self, forKey: .receipt)
        shops = try? container.decode([Shop].self, forKey: .shops)
        receipts = try? container.decode([Receipt].self, forKey: .receipts)
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
    }

    public init(amount: Int64,
                orderId: String,
                customerKey: String?,
                redirectDueDate: Date? = nil,
                payType: PayType? = nil)
    {
        self.amount = amount
        self.orderId = orderId
        self.customerKey = customerKey
        self.redirectDueDate = redirectDueDate
        self.payType = payType
    }

    public init(amount: NSDecimalNumber,
                orderId: String,
                customerKey: String?,
                redirectDueDate: Date? = nil,
                payType: PayType? = nil)
    {
        let int64Amount = Int64(amount.doubleValue * 100)
        self.init(amount: int64Amount, orderId: orderId, customerKey: customerKey, redirectDueDate: redirectDueDate, payType: payType)
    }
}

///
/// Инициирует платёжную сессию и регистрирует заказ в системе Банка.
public final class PaymentInitRequest: RequestOperation, AcquiringRequestTokenParams {
    // MARK: RequestOperation

    public var name = "Init"
    public var parameters: JSONObject?

    // MARK: AcquiringRequestTokenParams

    ///
    /// отмечаем параметры которые участвуют в вычислении `token`
    public var tokenParamsKey: Set<String> = [PaymentInitData.CodingKeys.amount.rawValue,
                                              PaymentInitData.CodingKeys.orderId.rawValue,
                                              PaymentInitData.CodingKeys.customerKey.rawValue,
                                              PaymentInitData.CodingKeys.savingAsParentPayment.rawValue]

    ///
    /// - Parameter data: `PaymentInitPaymentData`
    public init(data: PaymentInitData) {
        if let json = try? data.encode2JSONObject(dateEncodingStrategy: .iso8601) {
            parameters = json
        }
    }
}

///
public struct PaymentInitResponse: ResponseOperation {
    public var success: Bool
    public var errorCode: Int
    public var errorMessage: String?
    public var errorDetails: String?
    public var terminalKey: String?
    //
    public var amount: Int64
    public var orderId: String
    public var paymentId: Int64
    public var status: PaymentStatus

    private enum CodingKeys: String, CodingKey {
        case success = "Success"
        case errorCode = "ErrorCode"
        case errorMessage = "Message"
        case errorDetails = "Details"
        case terminalKey = "TerminalKey"
        //
        case amount = "Amount"
        case orderId = "OrderId"
        case paymentId = "PaymentId"
        case status = "Status"
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        success = try container.decode(Bool.self, forKey: .success)
        errorCode = try Int(container.decode(String.self, forKey: .errorCode))!
        errorMessage = try? container.decode(String.self, forKey: .errorMessage)
        errorDetails = try? container.decode(String.self, forKey: .errorDetails)
        terminalKey = try? container.decode(String.self, forKey: .terminalKey)
        //
        amount = try container.decode(Int64.self, forKey: .amount)
        /// orderId
        orderId = try container.decode(String.self, forKey: .orderId)
        /// paymentId
        if let stringValue = try? container.decode(String.self, forKey: .paymentId), let value = Int64(stringValue) {
            paymentId = value
        } else {
            paymentId = try container.decode(Int64.self, forKey: .paymentId)
        }

        if let statusValue = try? container.decode(String.self, forKey: .status) {
            status = PaymentStatus(rawValue: statusValue)
        } else {
            status = .unknown
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(success, forKey: .success)
        try container.encode(errorCode, forKey: .errorCode)
        try? container.encode(errorMessage, forKey: .errorMessage)
        try? container.encode(errorDetails, forKey: .errorDetails)
        //
        try container.encode(amount, forKey: .amount)
        try container.encode(orderId, forKey: .orderId)
        try container.encode(paymentId, forKey: .paymentId)
        try container.encode(status.rawValue, forKey: .status)
        try container.encode(terminalKey, forKey: .terminalKey)
    }
}

public struct PaymentInitResponseData {
    public let amount: Int64
    public let orderId: String
    public let paymentId: Int64

    public init(amount: Int64,
                orderId: String,
                paymentId: Int64)
    {
        self.amount = amount
        self.orderId = orderId
        self.paymentId = paymentId
    }

    public init(paymentInitResponse: PaymentInitResponse) {
        amount = paymentInitResponse.amount
        orderId = paymentInitResponse.orderId
        paymentId = paymentInitResponse.paymentId
    }
}
