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

public struct AttachCardPayload: Decodable {
    private enum CodingKeys: CodingKey {
        case status
        case requestKey
        case cardId

        var stringValue: String {
            switch self {
            case .status: return Constants.Keys.status
            case .requestKey: return Constants.Keys.requestKey
            case .cardId: return Constants.Keys.cardId
            }
        }
    }

    public let status: PaymentStatus
    public let requestKey: String
    public let cardId: String?
    public let attachCardStatus: AttachCardStatus

    public init(
        status: PaymentStatus,
        requestKey: String,
        cardId: String?,
        attachCardStatus: AttachCardStatus
    ) {
        self.status = status
        self.requestKey = requestKey
        self.cardId = cardId
        self.attachCardStatus = attachCardStatus
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        status = try container.decodeIfPresent(PaymentStatus.self, forKey: .status) ?? .unknown
        requestKey = try container.decode(String.self, forKey: .requestKey)
        cardId = try container.decodeIfPresent(String.self, forKey: .cardId)

        switch status {
        case .checking3ds, .hold3ds:
            if let confirmation3DS = try? Confirmation3DSData(from: decoder) {
                attachCardStatus = .needConfirmation3DS(confirmation3DS)
            } else if let confirmation3DSACS = try? Confirmation3DSDataACS(from: decoder) {
                attachCardStatus = .needConfirmation3DSACS(confirmation3DSACS)
            } else {
                throw DecodingError.typeMismatch(
                    FinishAuthorizePayload.self,
                    DecodingError.Context(
                        codingPath: decoder.codingPath,
                        debugDescription: "AttachCard must has Confirmation3DSData or Confirmation3DSDataACS if status is 3DS_CHECKING or 3DSHOLD"
                    )
                )
            }
        case .loop:
            let requestKey = try container.decode(String.self, forKey: .requestKey)
            attachCardStatus = .needConfirmationRandomAmount(requestKey)
        default:
            attachCardStatus = .done
        }
    }
}
