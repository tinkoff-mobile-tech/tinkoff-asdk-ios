//
//
//  PaymentFinishResponse.swift
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

public struct PaymentFinishResponse: ResponseOperation {
    public var success: Bool
    public var errorCode: Int
    public var errorMessage: String?
    public var errorDetails: String?
    public var terminalKey: String?
    public var paymentStatus: PaymentStatus
    // Поля для удачного статуса, совершенного платежа, завершаем процесс оплаты
    public var responseStatus: PaymentFinishResponseStatus

    private enum CodingKeys: String, CodingKey {
        case success = "Success"
        case errorCode = "ErrorCode"
        case errorMessage = "Message"
        case errorDetails = "Details"
        case terminalKey = "TerminalKey"
        // по этому полю определяем статус платежа
        case paymentStatus = "Status"
        case responseStatus
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        success = try container.decode(Bool.self, forKey: .success)
        errorCode = try Int(container.decode(String.self, forKey: .errorCode))!
        errorMessage = try? container.decode(String.self, forKey: .errorMessage)
        errorDetails = try? container.decode(String.self, forKey: .errorDetails)
        terminalKey = try? container.decode(String.self, forKey: .terminalKey)
        //
        paymentStatus = .unknown
        if let statusValue = try? container.decode(String.self, forKey: .paymentStatus) {
            paymentStatus = PaymentStatus(rawValue: statusValue)
        }

        responseStatus = .unknown
        switch paymentStatus {
        case .checking3ds:
            if let confirmation3DS = try? Confirmation3DSData(from: decoder) {
                responseStatus = .needConfirmation3DS(confirmation3DS)
            } else if let confirmation3DSACS = try? Confirmation3DSDataACS(from: decoder) {
                responseStatus = .needConfirmation3DSACS(confirmation3DSACS)
            } else if let confirmationAppBased = try? Confirmation3DS2AppBasedData(from: decoder) {
                responseStatus = .needConfirmation3DS2AppBased(confirmationAppBased)
            }

        case .authorized, .confirmed, .checked3ds:
            if let finishStatus = try? PaymentStatusResponse(from: decoder) {
                responseStatus = .done(finishStatus)
            }

        default:
            if let finishStatus = try? PaymentStatusResponse(from: decoder) {
                responseStatus = .done(finishStatus)
            }
        }
    } // init

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
        case let .done(responseStatus):
            try responseStatus.encode(to: encoder)
        default:
            break
        }
    } // encode
} // PaymentFinishResponse
