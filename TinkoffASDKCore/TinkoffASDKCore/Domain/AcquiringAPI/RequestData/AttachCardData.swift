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

public struct AttachCardData {
    let cardNumber: String
    let expDate: String
    let cvv: String
    let requestKey: String
    let data: FinishAuthorizeDataEnum?

    public init(
        cardNumber: String,
        expDate: String,
        cvv: String,
        requestKey: String,
        data: FinishAuthorizeDataWrapper<ThreeDsDataBrowser>?
    ) {
        self.cardNumber = cardNumber
        self.expDate = expDate
        self.cvv = cvv
        self.requestKey = requestKey

        if let data = data {
            // В данный момент на МАПИ поддерживается только 3ds Browser Flow
            self.data = .threeDsBrowser(data)
        } else {
            self.data = nil
        }
    }

    func cardData() -> String {
        return "\(Constants.Keys.cardNumber)=\(cardNumber);\(Constants.Keys.cardExpDate)=\(expDate);\(Constants.Keys.cardCVV)=\(cvv)"
    }
}
