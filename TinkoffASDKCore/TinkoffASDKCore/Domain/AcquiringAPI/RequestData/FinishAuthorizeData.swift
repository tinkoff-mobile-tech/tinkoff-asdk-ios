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
    /// Номер платежа, полученного после инициализации платежа
    let paymentId: String
    let paymentSource: PaymentSourceData
    let infoEmail: String?
    let sendEmail: Bool?
    let deviceInfo: ThreeDSDeviceInfo?
    let threeDSVersion: String?
    let source: String?
    let route: String?

    public init(
        paymentId: String,
        paymentSource: PaymentSourceData,
        infoEmail: String? = nil,
        deviceInfo: ThreeDSDeviceInfo? = nil,
        threeDSVersion: String? = nil,
        source: String? = nil,
        route: String? = nil
    ) {
        self.paymentId = paymentId
        self.paymentSource = paymentSource
        self.infoEmail = infoEmail
        sendEmail = infoEmail != nil
        self.deviceInfo = deviceInfo
        self.threeDSVersion = threeDSVersion
        self.source = source
        self.route = route
    }
}
