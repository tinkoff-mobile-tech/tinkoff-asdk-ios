//
//
//  CardListResponse.swift
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

public struct CardListResponse: ResponseOperation {
    private enum CodingKeys: CodingKey {
        case success
        case errorCode
        case errorMessage
        case errorDetails
        case terminalKey
        case cards

        var stringValue: String {
            switch self {
            case .success: return APIConstants.Keys.success
            case .errorCode: return APIConstants.Keys.errorCode
            case .errorMessage: return APIConstants.Keys.errorMessage
            case .errorDetails: return APIConstants.Keys.errorDetails
            case .terminalKey: return APIConstants.Keys.terminalKey
            case .cards: return APIConstants.Keys.cards
            }
        }
    }

    public var success = true
    public var errorCode: Int = 0
    public var errorMessage: String?
    public var errorDetails: String?
    public var terminalKey: String?
    public var cards: [PaymentCard]

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        success = try container.decode(Bool.self, forKey: .success)
        errorCode = try container.decode(Int.self, forKey: .errorCode)
        errorMessage = try? container.decode(String.self, forKey: .errorMessage)
        errorDetails = try? container.decode(String.self, forKey: .errorDetails)
        terminalKey = try? container.decode(String.self, forKey: .terminalKey)
        //
        cards = try container.decode([PaymentCard].self, forKey: .cards)
    }

    public init(from decoder: Decoder, cardsList: [PaymentCard]) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        success = try container.decode(Bool.self, forKey: .success)
        errorCode = try container.decode(Int.self, forKey: .errorCode)
        errorMessage = try? container.decode(String.self, forKey: .errorMessage)
        errorDetails = try? container.decode(String.self, forKey: .errorDetails)
        terminalKey = try? container.decode(String.self, forKey: .terminalKey)
        //
        cards = cardsList
    }
}
