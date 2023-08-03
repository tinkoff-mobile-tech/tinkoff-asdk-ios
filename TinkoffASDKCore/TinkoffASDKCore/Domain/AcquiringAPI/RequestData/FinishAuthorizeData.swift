//
//
//  FinishAuthorizeData.swift
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

public struct FinishAuthorizeData {
    let paymentSource: PaymentSourceData

    /// Уникальный идентификатор транзакции в системе Тинькофф Кассы
    public let paymentId: String

    /// Email для отправки информации об оплате. Обязателен при передаче SendEmail
    public let infoEmail: String?

    /// true – отправлять клиенту информацию на почту об оплате
    /// false – не отправлять
    public let sendEmail: Bool?

    /// Сумма в копейках
    /// number <= 10 characters
    public let amount: Int?

    /// JSON объект, содержащий дополнительные параметры в виде ключ:значение.
    /// Данные параметры будут переданы на страницу оплаты (в случае ее кастомизации).
    /// Максимальная длина для каждого передаваемого параметра:
    ///
    /// Ключ - 20 знаков
    /// Значение - 100 знаков.
    /// Максимальное количество пар ключ:значение не может превышать 20
    public let data: FinishAuthorizeDataEnum?

    /// Канал устройства. Поддерживается следующий канал устройства:
    /// 01 = Application (APP)
    /// 02 = Browser (BRW)
    public var deviceChannel: String? { DeviceChannel.create(from: data) }

    public init(
        paymentId: String,
        paymentSource: PaymentSourceData,
        infoEmail: String?,
        amount: Int? = nil,
        data: FinishAuthorizeDataEnum?
    ) {
        self.paymentId = paymentId
        self.paymentSource = paymentSource
        self.infoEmail = infoEmail
        sendEmail = infoEmail != nil
        self.amount = amount
        self.data = data
    }
}
