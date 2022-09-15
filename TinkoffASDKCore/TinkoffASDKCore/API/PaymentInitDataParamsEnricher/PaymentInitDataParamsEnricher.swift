//
//
//  PaymentInitDataParamsEnricher.swift
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
import class UIKit.UIDevice

protocol IPaymentInitDataParamsEnricher {
    func enrich(_ paymentInitData: PaymentInitData) -> PaymentInitData
}

final class PaymentInitDataParamsEnricher: IPaymentInitDataParamsEnricher {
    func enrich(_ paymentInitData: PaymentInitData) -> PaymentInitData {
        var paymentData = paymentInitData

        let additionalParams: [String: String] = [
            .connectionType: String.mobileSDK,
            .version: Version.versionString,
            .softwareVersion: UIDevice.current.systemVersion,
            .deviceModel: UIDevice.current.deviceModel
        ]
        
        paymentData.addPaymentData(additionalParams)
        return paymentData
    }
}

// MARK: - Constants

private extension String {
    static let mobileSDK = "mobile_sdk"
    static let connectionType = "connection_type"
    static let version = "sdk_version"
    static let softwareVersion = "software_version"
    static let deviceModel = "device_model"
}
