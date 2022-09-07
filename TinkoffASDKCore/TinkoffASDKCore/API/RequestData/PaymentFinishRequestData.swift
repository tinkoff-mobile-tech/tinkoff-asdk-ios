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

public struct PaymentFinishRequestData: Codable {
    /// Номер платежа, полученного после инициализации платежа
    var paymentId: Int64
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

    enum CodingKeys: String, CodingKey {
        case paymentId = "PaymentId"
        case paymentSource = "PaymentSource"
        case sendEmail = "SendEmail"
        case infoEmail = "InfoEmail"
        case cardData = "CardData"
        case encryptedPaymentData = "EncryptedPaymentData"
        case deviceInfo = "DATA"
        case ipAddress = "IP"
        case source = "Source"
        case route = "Route"
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        paymentId = try container.decode(Int64.self, forKey: .paymentId)
        paymentSource = try container.decode(PaymentSourceData.self, forKey: .paymentSource)
        sendEmail = try? container.decode(Bool.self, forKey: .sendEmail)
        infoEmail = try? container.decode(String.self, forKey: .infoEmail)
        deviceInfo = try? container.decode(DeviceInfoParams.self, forKey: .deviceInfo)
        ipAddress = try? container.decode(String.self, forKey: .ipAddress)
        source = try? container.decode(String.self, forKey: .source)
        route = try? container.decode(String.self, forKey: .route)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(paymentId, forKey: .paymentId)
        try container.encode(paymentSource, forKey: .paymentSource)
        if sendEmail != nil { try? container.encode(sendEmail, forKey: .sendEmail) }
        if infoEmail != nil { try? container.encode(infoEmail, forKey: .infoEmail) }
        if deviceInfo != nil { try? container.encode(deviceInfo, forKey: .deviceInfo) }
        if ipAddress != nil { try? container.encode(ipAddress, forKey: .ipAddress) }
        if source != nil { try? container.encode(source, forKey: .source) }
        if route != nil { try? container.encode(route, forKey: .route) }
    }
}
