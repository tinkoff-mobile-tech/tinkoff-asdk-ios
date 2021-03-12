//
//
//  PaymentFinishRequestData.swift
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

public struct PaymentFinishRequestData {
    /// Номер платежа, полученного после инициализации платежа
    public var paymentId: PaymentId
    public var paymentSource: PaymentSourceData

    var sendEmail: Bool?
    var infoEmail: String?
    var deviceInfo: DeviceInfoParams?
    var ipAddress: String?
    var threeDSVersion: String?
    
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

    public init(paymentId: PaymentId, paymentSource: PaymentSourceData) {
        self.paymentId = paymentId
        self.paymentSource = paymentSource
    }
}
