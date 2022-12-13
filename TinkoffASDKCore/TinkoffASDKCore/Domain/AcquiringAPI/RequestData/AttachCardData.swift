//
//
//  AttachCardData.swift
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

@available(*, deprecated, renamed: "AttachCardData")
public typealias FinishAddCardData = AttachCardData

public struct AttachCardData {
    let cardNumber: String
    let expDate: String
    let cvv: String
    let requestKey: String
    let deviceData: DeviceInfoParams?

    public init(
        cardNumber: String,
        expDate: String,
        cvv: String,
        requestKey: String,
        deviceData: DeviceInfoParams? = nil
    ) {
        self.cardNumber = cardNumber
        self.expDate = expDate
        self.cvv = cvv
        self.requestKey = requestKey
        self.deviceData = deviceData
    }

    func cardData() -> String {
        return "\(Constants.Keys.cardNumber)=\(cardNumber);\(Constants.Keys.cardExpDate)=\(expDate);\(Constants.Keys.cardCVV)=\(cvv)"
    }
}
