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

public struct OrderOptions: Equatable {
    let orderId: String
    let amount: Int64
    let description: String?
    let receipt: Receipt?
    let shops: [Shop]?
    let receipts: [Receipt]?
    let savingAsParentPayment: Bool

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
