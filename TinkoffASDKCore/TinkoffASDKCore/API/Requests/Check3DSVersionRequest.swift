//
//
//  Check3DSVersionRequest.swift
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

struct Check3DSVersionRequest: APIRequest {
    typealias Payload = Check3DSVersionPayload

    let baseURL: URL
    let path: String = "v2/Check3dsVersion"
    let httpMethod: HTTPMethod = .post
    let parameters: HTTPParameters

    init(
        check3DSRequestData: Check3DSRequestData,
        encryptor: RSAEncryptor,
        cardDataFormatter: CardDataFormatter,
        publicKey: SecKey,
        baseURL: URL
    ) {
        self.baseURL = baseURL
        parameters = .create(
            requestData: check3DSRequestData,
            encryptor: encryptor,
            cardDataFormatter: cardDataFormatter,
            publicKey: publicKey
        )
    }
}

// MARK: - HTTPParameters + Helpers

private extension HTTPParameters {
    static func create(
        requestData: Check3DSRequestData,
        encryptor: RSAEncryptor,
        cardDataFormatter: CardDataFormatter,
        publicKey: SecKey
    ) -> HTTPParameters {
        var parameters: HTTPParameters = [APIConstants.Keys.paymentId: requestData.paymentId]

        switch requestData.paymentSource {
        case let .cardNumber(number, expDate, cvv):
            let formattedCardData = cardDataFormatter.formatCardData(cardNumber: number, expDate: expDate, cvv: cvv)

            if let encryptedCardData = try? encryptor.encrypt(string: formattedCardData, publicKey: publicKey) {
                parameters[APIConstants.Keys.cardData] = encryptedCardData
            }
        case let .savedCard(cardId, cvv):
            let formattedCardData = cardDataFormatter.formatCardData(cardId: cardId, cvv: cvv)

            if let encryptedCardData = try? encryptor.encrypt(string: formattedCardData, publicKey: publicKey) {
                parameters[APIConstants.Keys.cardData] = encryptedCardData
            }
        case let .paymentData(data):
            parameters[APIConstants.Keys.encryptedPaymentData] = data
            parameters[APIConstants.Keys.route] = APIConstants.Values.acq
            parameters[APIConstants.Keys.source] = APIConstants.Values.applePaySource
        default: break
        }

        return parameters
    }
}
