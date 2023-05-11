//
//
//  OrderOptions.swift
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

import TinkoffASDKCore

/// Параметры заказа
public struct OrderOptions: Equatable {
    /// Идентификатор заказа в системе продавца
    public let orderId: String
    /// Полная сумма заказа в копейках
    public let amount: Int64
    /// Краткое описание заказа
    public let description: String?
    /// Данные чека
    public let receipt: Receipt?
    /// Данные маркетплейса. Используется для разбивки платежа по партнерам
    public let shops: [Shop]?
    /// Чеки для каждого объекта `Shop`. В каждом чеке необходимо указывать `Receipt.shopCode` == `Shop.shopCode`
    public let receipts: [Receipt]?
    /// Сохранить платеж в качестве родительского
    public let savingAsParentPayment: Bool

    public init(
        orderId: String,
        amount: Int64,
        description: String? = nil,
        receipt: Receipt? = nil,
        shops: [Shop]? = nil,
        receipts: [Receipt]? = nil,
        savingAsParentPayment: Bool = false
    ) {
        self.orderId = orderId
        self.amount = amount
        self.description = description
        self.receipt = receipt
        self.shops = shops
        self.receipts = receipts
        self.savingAsParentPayment = savingAsParentPayment
    }
}
