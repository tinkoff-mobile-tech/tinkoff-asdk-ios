//
//
//  PaymentOptions.swift
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

/// Параметры платежа
public struct PaymentOptions: Equatable {
    /// Параметры заказа
    public let orderOptions: OrderOptions
    /// Параметры покупателя
    public let customerOptions: CustomerOptions?
    /// Ссылки для возврата на страницы успешной или неуспешной оплаты, используемые по завершении процесса оплаты во внешнем приложении
    ///
    /// Используется только для оплаты через `Tinkoff Pay`
    public let paymentCallbackURL: PaymentCallbackURL?
    /// `JSON` объект, содержащий дополнительные параметры в виде `[Key: Value]`
    ///
    /// `Key: String` – 20 знаков,
    /// `Value: String` – 100 знаков.
    /// - Warning: Максимальное количество пар параметров не может превышать 20.
    /// Часть может быть зарезервирована `TinkoffAcquiringSDK`
    public let paymentData: [String: String]?

    public init(
        orderOptions: OrderOptions,
        customerOptions: CustomerOptions? = nil,
        paymentCallbackURL: PaymentCallbackURL? = nil,
        paymentData: [String: String]? = nil
    ) {
        self.orderOptions = orderOptions
        self.customerOptions = customerOptions
        self.paymentCallbackURL = paymentCallbackURL
        self.paymentData = paymentData
    }
}
