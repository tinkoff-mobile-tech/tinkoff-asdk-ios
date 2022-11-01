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
    let deviceInfo: DeviceInfoParams?
    let ipAddress: String?
    let threeDSVersion: String?
    let source: String?
    let route: String?

    public init(
        paymentId: String,
        paymentSource: PaymentSourceData,
        infoEmail: String? = nil,
        deviceInfo: DeviceInfoParams? = nil,
        ipAddress: String? = nil,
        threeDSVersion: String? = nil,
        source: String? = nil,
        route: String? = nil
    ) {
        self.paymentId = paymentId
        self.paymentSource = paymentSource
        self.infoEmail = infoEmail
        sendEmail = infoEmail != nil
        self.deviceInfo = deviceInfo
        self.ipAddress = ipAddress
        self.threeDSVersion = threeDSVersion
        self.source = source
        self.route = route
    }

    public init(from request: PaymentFinishRequestData) {
        self = Self(
            paymentId: String(request.paymentId),
            paymentSource: request.paymentSource,
            infoEmail: request.infoEmail,
            deviceInfo: request.deviceInfo,
            ipAddress: request.ipAddress,
            threeDSVersion: request.threeDSVersion,
            source: request.source,
            route: request.route
        )
    }
}

public struct PaymentFinishRequestData {
    /// Номер платежа, полученного после инициализации платежа
    public var paymentId: Int64
    var paymentSource: PaymentSourceData

    var sendEmail: Bool?
    var infoEmail: String?
    var deviceInfo: DeviceInfoParams?
    var ipAddress: String?
    var threeDSVersion: String?

    var source: String?
    var route: String?

    public mutating func setDeviceInfo(info: DeviceInfoParams?) {
        deviceInfo = info
    }

    public mutating func setIpAddress(_ ip: String?) {
        ipAddress = ip
    }

    public mutating func setThreeDSVersion(_ version: String?) {
        threeDSVersion = version
    }

    public mutating func setInfoEmail(_ email: String?) {
        infoEmail = email
        if email != nil {
            sendEmail = true
        }
    }

    public init(paymentId: Int64, paymentSource: PaymentSourceData) {
        self.paymentId = paymentId
        self.paymentSource = paymentSource
    }

    public init(paymentId: Int64, paymentSource: PaymentSourceData, source: String, route: String) {
        self.paymentId = paymentId
        self.paymentSource = paymentSource
        self.source = source
        self.route = route
    }
}
