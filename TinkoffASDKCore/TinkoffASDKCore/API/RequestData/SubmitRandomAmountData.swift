//
//
//  SubmitRandomAmountData.swift
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

public struct SubmitRandomAmountData: Codable {
    // Сумма в копейках
    let amount: Int64
    // Идентификатор запроса на привязку карты
    let requestKey: String
    
    enum CodingKeys: CodingKey {
        case amount
        case requestKey
        
        var stringValue: String {
            switch self {
            case .amount: return APIConstants.Keys.amount
            case .requestKey: return APIConstants.Keys.requestKey
            }
        }
    }
    
    public init(amount: Int64, requestKey: String) {
        self.amount = amount
        self.requestKey = requestKey
    }
}
