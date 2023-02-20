//
//
//  FinishAddCardResponse.swift
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

public struct FinishAddCardResponse: ResponseOperation {
    private enum CodingKeys: CodingKey {
        case success
        case errorCode
        case errorMessage
        case errorDetails
        case terminalKey
        case paymentStatus
        //
        case requestKey
        case cardId

        var stringValue: String {
            switch self {
            case .success: return Constants.Keys.success
            case .errorCode: return Constants.Keys.errorCode
            case .errorMessage: return Constants.Keys.errorMessage
            case .errorDetails: return Constants.Keys.errorDetails
            case .terminalKey: return Constants.Keys.terminalKey
            case .paymentStatus: return Constants.Keys.status
            case .requestKey: return Constants.Keys.requestKey
            case .cardId: return Constants.Keys.cardId
            }
        }
    }

    public var success: Bool
    public var errorCode: Int
    public var errorMessage: String?
    public var errorDetails: String?
    public var terminalKey: String?
    public var paymentStatus: AcquiringStatus
    public var responseStatus: AddCardFinishResponseStatus
    //
    var cardId: String?

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        success = try container.decode(Bool.self, forKey: .success)
        errorCode = try Int(container.decode(String.self, forKey: .errorCode))!
        errorMessage = try? container.decode(String.self, forKey: .errorMessage)
        errorDetails = try? container.decode(String.self, forKey: .errorDetails)
        terminalKey = try? container.decode(String.self, forKey: .terminalKey)

        paymentStatus = .unknown
        if let statusValue = try? container.decode(String.self, forKey: .paymentStatus) {
            paymentStatus = AcquiringStatus(rawValue: statusValue)
        }

        responseStatus = .unknown
        switch paymentStatus {
        case .checking3ds, .hold3ds:
            if let confirmation3DS = try? Confirmation3DSData(from: decoder) {
                responseStatus = .needConfirmation3DS(confirmation3DS)
            } else if let confirmation3DSACS = try? Confirmation3DSDataACS(from: decoder) {
                responseStatus = .needConfirmation3DSACS(confirmation3DSACS)
            }

        case .loop:
            let requestKey = try container.decode(String.self, forKey: .requestKey)
            responseStatus = .needConfirmationRandomAmount(requestKey)

        case .authorized, .confirmed, .checked3ds:
            if let finishStatus = try? AddCardStatusResponse(from: decoder) {
                responseStatus = .done(finishStatus)
            }

        default:
            if let finishStatus = try? AddCardStatusResponse(from: decoder) {
                responseStatus = .done(finishStatus)
            }
        }

        //
        cardId = try? container.decode(String.self, forKey: .cardId)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(success, forKey: .success)
        try container.encode(errorCode, forKey: .errorCode)
        try? container.encode(errorMessage, forKey: .errorMessage)
        try? container.encode(errorDetails, forKey: .errorDetails)
        try? container.encode(terminalKey, forKey: .terminalKey)

        switch responseStatus {
        case let .needConfirmation3DS(confirm3DSData):
            try confirm3DSData.encode(to: encoder)
        case let .needConfirmationRandomAmount(confirmRandomAmountData):
            try confirmRandomAmountData.encode(to: encoder)
        case let .done(responseStatus):
            try responseStatus.encode(to: encoder)
        default:
            break
        }
        //
        try? container.encode(cardId, forKey: .cardId)
    } // encode
} // FinishAddCardResponse
