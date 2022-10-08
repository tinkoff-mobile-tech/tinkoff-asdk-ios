//
//
//  FinishAuthorizePayload.swift
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

public struct FinishAuthorizePayload: Decodable {
    private enum CodingKeys: CodingKey {
        case rebillId

        var stringValue: String {
            switch self {
            case .rebillId: return Constants.Keys.rebillId
            }
        }
    }

    public let status: PaymentStatus
    public let paymentState: GetPaymentStatePayload
    public var responseStatus: PaymentFinishResponseStatus
    public let rebillId: String?

    public init(
        status: PaymentStatus,
        paymentState: GetPaymentStatePayload,
        responseStatus: PaymentFinishResponseStatus,
        rebillId: String? = nil
    ) {
        self.status = status
        self.paymentState = paymentState
        self.responseStatus = responseStatus
        self.rebillId = rebillId
    }

    public init(from decoder: Decoder) throws {
        paymentState = try GetPaymentStatePayload(from: decoder)
        status = paymentState.status

        responseStatus = .unknown

        switch status {
        case .checking3ds:
            if let confirmation3DS = try? Confirmation3DSData(from: decoder) {
                responseStatus = .needConfirmation3DS(confirmation3DS)
            } else if let confirmation3DSACS = try? Confirmation3DSDataACS(from: decoder) {
                responseStatus = .needConfirmation3DSACS(confirmation3DSACS)
            } else {
                throw DecodingError.typeMismatch(
                    Self.self,
                    DecodingError.Context(
                        codingPath: decoder.codingPath,
                        debugDescription: "FinishAuthorize must has Confirmation3DSData or Confirmation3DSDataACS if status is 3DS_CHECKING"
                    )
                )
            }
        default:
            if let finishStatus = try? PaymentStatusResponse(from: decoder) {
                responseStatus = .done(finishStatus)
            }
        }

        let container = try decoder.container(keyedBy: CodingKeys.self)
        rebillId = try container.decodeIfPresent(String.self, forKey: .rebillId)
    }
}
