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
    var cardNumber: String
    var expDate: String
    var cvv: String
    var requestKey: String

    enum CodingKeys: String, CodingKey {
        case cardNumber = "PAN"
        case expDate = "ExpDate"
        case cvv = "CVV"
        case requestKey = "RequestKey"
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        cardNumber = try container.decode(String.self, forKey: .cardNumber)
        expDate = try container.decode(String.self, forKey: .expDate)
        cvv = try container.decode(String.self, forKey: .cvv)
        requestKey = try container.decode(String.self, forKey: .requestKey)
    }

    public init(cardNumber: String, expDate: String, cvv: String, requestKey: String) {
        self.cardNumber = cardNumber
        self.expDate = expDate
        self.cvv = cvv
        self.requestKey = requestKey
    }

    func cardData() -> String {
        return "\(CodingKeys.cardNumber.rawValue)=\(cardNumber);\(CodingKeys.expDate.rawValue)=\(expDate);\(CodingKeys.cvv.rawValue)=\(cvv)"
    }
}
