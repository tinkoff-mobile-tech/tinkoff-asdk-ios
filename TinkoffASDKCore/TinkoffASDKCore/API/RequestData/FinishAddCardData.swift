//
//
//  FinishAddCardData.swift
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

public struct FinishAddCardData: Codable {
    enum CodingKeys: CodingKey {
        case cardNumber
        case expDate
        case cvv
        case requestKey

        var stringValue: String {
            switch self {
            case .cardNumber: return APIConstants.Keys.cardNumber
            case .expDate: return APIConstants.Keys.cardExpDate
            case .cvv: return APIConstants.Keys.cardCVV
            case .requestKey: return APIConstants.Keys.requestKey
            }
        }
    }

    let cardNumber: String
    let expDate: String
    let cvv: String
    let requestKey: String

    public init(cardNumber: String, expDate: String, cvv: String, requestKey: String) {
        self.cardNumber = cardNumber
        self.expDate = expDate
        self.cvv = cvv
        self.requestKey = requestKey
    }

    func cardData() -> String {
        return "\(CodingKeys.cardNumber.stringValue)=\(cardNumber);\(CodingKeys.expDate.stringValue)=\(expDate);\(CodingKeys.cvv.stringValue)=\(cvv)"
    }
}
