//
//
//  CardListPayload.swift
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

public struct CardListPayload: Decodable {
    public var success: Bool = true
    public var errorCode: Int = 0
    public var errorMessage: String?
    public var errorDetails: String?
    public var terminalKey: String?
    public let cards: [PaymentCard]

    private enum CodingKeys: String, CodingKey {
        case errorCode
        case success
        case errorMessage
        case errorDetails
        case terminalKey
        case cards = "Cards"

        var stringValue: String {
            switch self {
            case .cards: return APIConstants.Keys.cards
            case .errorCode: return APIConstants.Keys.errorCode
            case .success: return APIConstants.Keys.success
            case .errorMessage: return APIConstants.Keys.errorMessage
            case .errorDetails: return APIConstants.Keys.errorDetails
            case .terminalKey: return APIConstants.Keys.terminalKey
            }
        }
    }

    init(cards: [PaymentCard]) {
        self.cards = cards
    }

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
