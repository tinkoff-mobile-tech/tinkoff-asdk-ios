//
//  PaymentCardRequests.swift
//  TinkoffASDKCore
//
//  Copyright (c) 2020 Tinkoff Bank
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

// MARK: Список карт

public final class CardListRequest: RequestOperation, AcquiringRequestTokenParams {
    // MARK: RequestOperation

    public var name = "GetCardList"

    public var parameters: JSONObject?

    // MARK: AcquiringRequestTokenParams

    /// отмечаем параметры которые участвуют в вычислении `token`
    public var tokenParamsKey: Set<String> = [GetCardListData.CodingKeys.customerKey.rawValue]

    ///
    /// - Parameter requestData: `InitGetCardListData`
    public init(data: GetCardListData) {
        if let json = try? data.encode2JSONObject() {
            parameters = json
        }
    }
}

// MARK: Добавит карту

public final class InitAddCardRequest: RequestOperation, AcquiringRequestTokenParams {
    // MARK: RequestOperation

    public var name = "AddCard"

    public var parameters: JSONObject?

    // MARK: AcquiringRequestTokenParams

    ///
    /// отмечаем параметры которые участвуют в вычислении `token`
    public var tokenParamsKey: Set<String> = [
        InitAddCardData.CodingKeys.checkType.rawValue,
        InitAddCardData.CodingKeys.customerKey.rawValue,
    ]

    ///
    /// - Parameter requestData: `InitAddCardData`
    public init(requestData: InitAddCardData) {
        if let json = try? requestData.encode2JSONObject() {
            parameters = json
        }
    }
}

class FinishAddCardRequest: AcquiringRequestTokenParams, RequestOperation {
    // MARK: RequestOperation

    var name = "AttachCard"

    var parameters: JSONObject?

    // MARK: AcquiringRequestTokenParams

    ///
    /// отмечаем параметры которые участвуют в вычислении `token`
    var tokenParamsKey: Set<String> = [
        FinishAddCardData.CodingKeys.requestKey.stringValue,
        PaymentFinishRequestData.CodingKeys.cardData.stringValue,
    ]

    ///
    /// - Parameter requestData: `FinishAddCardData`
    init(requestData: FinishAddCardData) {
        parameters = [:]
        parameters?.updateValue(requestData.cardData(), forKey: PaymentFinishRequestData.CodingKeys.cardData.rawValue)
        parameters?.updateValue(requestData.requestKey, forKey: FinishAddCardData.CodingKeys.requestKey.stringValue)
    }
}

public enum AddCardFinishResponseStatus {
    /// Требуется подтверждение 3DS v1.0
    case needConfirmation3DS(Confirmation3DSData)

    /// Требуется подтверждение 3DS v2.0
    case needConfirmation3DSACS(Confirmation3DSDataACS)

    /// Требуется подтвержить оплату указать сумму из смс для `requestKey`
    case needConfirmationRandomAmount(String)

    /// Успешная оплата
    case done(AddCardStatusResponse)

    /// что-то пошло не так
    case unknown
}

public struct AddCardStatusResponse: ResponseOperation {
    public var success: Bool
    public var errorCode: Int
    public var errorMessage: String?
    public var errorDetails: String?
    public var terminalKey: String?
    //
    public var requestKey: String?
    public var cardId: String?

    private enum CodingKeys: String, CodingKey {
        case success = "Success"
        case errorCode = "ErrorCode"
        case errorMessage = "Message"
        case errorDetails = "Details"
        case terminalKey = "TerminalKey"
        //
        case requestKey = "RequestKey"
        case cardId = "CardId"
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        success = try container.decode(Bool.self, forKey: .success)
        errorCode = try Int(container.decode(String.self, forKey: .errorCode))!
        errorMessage = try? container.decode(String.self, forKey: .errorMessage)
        errorDetails = try? container.decode(String.self, forKey: .errorDetails)
        terminalKey = try? container.decode(String.self, forKey: .terminalKey)
        //
        requestKey? = try container.decode(String.self, forKey: .requestKey)
        cardId = try? container.decode(String.self, forKey: .cardId)
    }

    public init(success: Bool, errorCode: Int) {
        self.success = success
        self.errorCode = errorCode
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(success, forKey: .success)
        try container.encode(errorCode, forKey: .errorCode)
        try? container.encode(errorMessage, forKey: .errorMessage)
        try? container.encode(errorDetails, forKey: .errorDetails)
        //
        try? container.encode(terminalKey, forKey: .terminalKey)
        try? container.encode(cardId, forKey: .cardId)
    }
} // AddCardStatusResponse

// MARK: Удалить карту

public final class InitDeactivateCardRequest: RequestOperation, AcquiringRequestTokenParams {
    // MARK: RequestOperation

    public var name = "RemoveCard"

    public var parameters: JSONObject?

    // MARK: AcquiringRequestTokenParams

    ///
    /// отмечаем параметры которые участвуют в вычислении `token`
    public var tokenParamsKey: Set<String> = [
        InitDeactivateCardData.CodingKeys.cardId.rawValue,
        InitDeactivateCardData.CodingKeys.customerKey.rawValue,
    ]

    ///
    /// - Parameter requestData: `InitDeactivateCardData`
    public init(requestData: InitDeactivateCardData) {
        if let json = try? requestData.encode2JSONObject() {
            parameters = json
        }
    }
}
