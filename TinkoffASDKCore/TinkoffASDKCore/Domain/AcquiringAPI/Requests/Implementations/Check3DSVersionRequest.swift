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

struct Check3DSVersionRequest: AcquiringRequest {
    let baseURL: URL
    let path: String = "v2/Check3dsVersion"
    let httpMethod: HTTPMethod = .post
    let parameters: HTTPParameters
    let terminalKeyProvidingStrategy: TerminalKeyProvidingStrategy = .always
    let tokenFormationStrategy: TokenFormationStrategy = .includeAll()

    init(
        check3DSRequestData: Check3DSVersionData,
        encryptor: IRSAEncryptor,
        cardDataFormatter: ICardDataFormatter,
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
        requestData: Check3DSVersionData,
        encryptor: IRSAEncryptor,
        cardDataFormatter: ICardDataFormatter,
        publicKey: SecKey
    ) -> HTTPParameters {
        var parameters: HTTPParameters = [Constants.Keys.paymentId: requestData.paymentId]

        switch requestData.paymentSource {
        case let .cardNumber(number, expDate, cvv):
            let formattedCardData = cardDataFormatter.formatCardData(cardNumber: number, expDate: expDate, cvv: cvv)

            if let encryptedCardData = encryptor.encrypt(string: formattedCardData, publicKey: publicKey) {
                parameters[Constants.Keys.cardData] = encryptedCardData
            }
        case let .savedCard(cardId, cvv):
            let formattedCardData = cardDataFormatter.formatCardData(cardId: cardId, cvv: cvv)

            if let encryptedCardData = encryptor.encrypt(string: formattedCardData, publicKey: publicKey) {
                parameters[Constants.Keys.cardData] = encryptedCardData
            }
        default: break
        }

        return parameters
    }
}
