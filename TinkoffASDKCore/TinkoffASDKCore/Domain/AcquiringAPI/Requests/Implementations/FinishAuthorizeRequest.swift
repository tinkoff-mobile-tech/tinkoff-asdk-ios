//
//
//  FinishAuthorizeRequest.swift
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

struct FinishAuthorizeRequest: AcquiringRequest {
    let baseURL: URL
    let path: String = "v2/FinishAuthorize"
    let httpMethod: HTTPMethod = .post
    let parameters: HTTPParameters
    let terminalKeyProvidingStrategy: TerminalKeyProvidingStrategy = .always
    let tokenFormationStrategy: TokenFormationStrategy = .includeAll(except: Constants.Keys.data)

    init(
        requestData: FinishAuthorizeData,
        encryptor: IRSAEncryptor,
        cardDataFormatter: ICardDataFormatter,
        ipAddressProvider: IIPAddressProvider,
        environmentParametersProvider: IEnvironmentParametersProvider,
        publicKey: SecKey,
        baseURL: URL
    ) {
        self.baseURL = baseURL
        parameters = .parameters(
            requestData: requestData,
            encryptor: encryptor,
            cardDataFormatter: cardDataFormatter,
            ipAddressProvider: ipAddressProvider,
            environmentParametersProvider: environmentParametersProvider,
            publicKey: publicKey
        )
    }
}

// MARK: - HTTPParameters + Helpers

private extension HTTPParameters {
    static func parameters(
        requestData: FinishAuthorizeData,
        encryptor: IRSAEncryptor,
        cardDataFormatter: ICardDataFormatter,
        ipAddressProvider: IIPAddressProvider,
        environmentParametersProvider: IEnvironmentParametersProvider,
        publicKey: SecKey
    ) -> HTTPParameters {
        var parameters: HTTPParameters = [Constants.Keys.paymentId: requestData.paymentId]

        if let sendEmail = requestData.sendEmail {
            parameters[Constants.Keys.sendEmail] = sendEmail
        }

        if let infoEmail = requestData.infoEmail {
            parameters[Constants.Keys.infoEmail] = infoEmail
        }

        if let ipAddress = ipAddressProvider.ipAddress?.fullStringValue {
            parameters[Constants.Keys.ipAddress] = ipAddress
        }

        if let deviceChannel = requestData.deviceChannel {
            parameters[Constants.Keys.deviceChannel] = deviceChannel
        }

        if let amount = requestData.amount {
            parameters[Constants.Keys.amount] = amount
        }

        let dataParameters = (try? requestData.data?.encode2JSONObject()) ?? [:]

        parameters[Constants.Keys.data] = dataParameters
            .merging(environmentParametersProvider.environmentParameters) { $1 }

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
        case let .yandexPay(base64Token):
            parameters[Constants.Keys.encryptedPaymentData] = base64Token
            parameters[Constants.Keys.route] = Constants.Values.acq
            parameters[Constants.Keys.source] = Constants.Values.yandexPaySource
        case .parentPayment:
            break
        }

        return parameters
    }
}
