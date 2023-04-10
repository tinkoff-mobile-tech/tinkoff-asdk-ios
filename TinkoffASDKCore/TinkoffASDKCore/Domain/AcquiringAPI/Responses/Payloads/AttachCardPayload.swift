//
//
//  AttachCardPayload.swift
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

/// Ответ сервера на запрос `AttachCard`
public struct AttachCardPayload {
    /// Статус привзязки карты
    public let status: AcquiringStatus
    /// Идентификатор запроса на привязку карты
    public let requestKey: String
    /// Идентификатор карты в системе банка
    public let cardId: String?
    /// Идентификатор рекуррентного платежа
    public let rebillId: String?
    /// Дополнительная информация о дальнейших действиях для успешной привязки карты
    public let attachCardStatus: AttachCardStatus

    /// Ответ сервера на запрос `AttachCard`
    /// - Parameters:
    ///   - status: Статус привзязки карты
    ///   - requestKey: Идентификатор запроса на привязку карты
    ///   - cardId: Идентификатор карты в системе банка
    ///   - rebillId: Идентификатор рекуррентного платежа
    ///   - attachCardStatus: Дополнительная информация о дальнейших действиях для успешной привязки карты
    public init(
        status: AcquiringStatus,
        requestKey: String,
        cardId: String?,
        rebillId: String?,
        attachCardStatus: AttachCardStatus
    ) {
        self.status = status
        self.requestKey = requestKey
        self.cardId = cardId
        self.rebillId = rebillId
        self.attachCardStatus = attachCardStatus
    }
}

// MARK: - Decodable

extension AttachCardPayload: Decodable {
    private enum CodingKeys: CodingKey {
        case status
        case requestKey
        case cardId
        case rebillId

        var stringValue: String {
            switch self {
            case .status: return Constants.Keys.status
            case .requestKey: return Constants.Keys.requestKey
            case .cardId: return Constants.Keys.cardId
            case .rebillId: return Constants.Keys.rebillId
            }
        }
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        status = try container.decodeIfPresent(AcquiringStatus.self, forKey: .status) ?? .unknown
        requestKey = try container.decode(String.self, forKey: .requestKey)
        cardId = try container.decodeIfPresent(String.self, forKey: .cardId)
        rebillId = try container.decodeIfPresent(String.self, forKey: .rebillId)

        switch status {
        case .checking3ds, .hold3ds:
            if let confirmation3DS = try? Confirmation3DSData(from: decoder) {
                attachCardStatus = .needConfirmation3DS(confirmation3DS)
            } else if let confirmation3DSACS = try? Confirmation3DSDataACS(from: decoder) {
                attachCardStatus = .needConfirmation3DSACS(confirmation3DSACS)
            } else if let confirmation3DSAppBasedData = try? Confirmation3DS2AppBasedData(from: decoder) {
                attachCardStatus = .needConfirmation3DS2AppBased(confirmation3DSAppBasedData)
            } else {
                throw DecodingError.typeMismatch(
                    FinishAuthorizePayload.self,
                    DecodingError.Context(
                        codingPath: decoder.codingPath,
                        debugDescription: "AttachCard must has Confirmation3DSData or Confirmation3DSDataACS if status is 3DS_CHECKING or 3DSHOLD"
                    )
                )
            }
        default:
            attachCardStatus = .done
        }
    }
}
