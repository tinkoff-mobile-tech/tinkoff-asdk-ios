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

struct FinishAuthorizeRequest: APIRequest {
    typealias Payload = FinishAuthorizePayload
    
    var requestPath: [String] { ["FinishAuthorize"] }
    var httpMethod: HTTPMethod { .post }
    var baseURL: URL
    let parameters: HTTPParameters

    init(
        requestData: FinishPaymentRequestData,
        encryptor: RSAEncryptor,
        cardDataFormatter: CardDataFormatter,
        publicKey: SecKey,
        baseURL: URL
    ) {
        self.baseURL = baseURL
        self.parameters = Self.createParameters(
            paymentId: requestData.paymentId,
            paymentSource: requestData.paymentSource,
            infoEmail: requestData.infoEmail,
            sendEmail: requestData.sendEmail,
            deviceInfo: requestData.deviceInfo,
            ipAddress: requestData.ipAddress,
            threeDSVersion: requestData.threeDSVersion,
            source: requestData.source,
            route: requestData.route,
            encryptor: encryptor,
            cardDataFormatter: cardDataFormatter,
            publicKey: publicKey
        )
    }

    @available(*, deprecated, message: "Use init(requestData:encryptor:cardDataFormatter:publicKey:baseURL) instead")
    init(
        paymentFinishRequestData: PaymentFinishRequestData,
        encryptor: RSAEncryptor,
        cardDataFormatter: CardDataFormatter,
        publicKey: SecKey,
        baseURL: URL
    ) {
        self.baseURL = baseURL
        self.parameters = Self.createParameters(
            paymentId: paymentFinishRequestData.paymentId.description,
            paymentSource: paymentFinishRequestData.paymentSource,
            infoEmail: paymentFinishRequestData.infoEmail,
            sendEmail: paymentFinishRequestData.sendEmail,
            deviceInfo: paymentFinishRequestData.deviceInfo,
            ipAddress: paymentFinishRequestData.ipAddress,
            threeDSVersion: paymentFinishRequestData.threeDSVersion,
            source: paymentFinishRequestData.threeDSVersion,
            route: paymentFinishRequestData.route,
            encryptor: encryptor,
            cardDataFormatter: cardDataFormatter,
            publicKey: publicKey
        )
    }
}

private extension FinishAuthorizeRequest {
    static func createParameters(
        paymentId: PaymentId,
        paymentSource: PaymentSourceData,
        infoEmail: String?,
        sendEmail: Bool?,
        deviceInfo: DeviceInfoParams?,
        ipAddress: String?,
        threeDSVersion: String?,
        source: String?,
        route: String?,
        encryptor: RSAEncryptor,
        cardDataFormatter: CardDataFormatter,
        publicKey: SecKey
    ) -> HTTPParameters {
        var parameters: HTTPParameters = [APIConstants.Keys.paymentId: paymentId]
        if let sendEmail = sendEmail {
            parameters[APIConstants.Keys.sendEmail] = sendEmail
        }
        if let infoEmail = infoEmail {
            parameters[APIConstants.Keys.infoEmail] = infoEmail
        }
        if let ipAddress = ipAddress {
            parameters[APIConstants.Keys.ipAddress] = ipAddress
        }
        if let deviceInfo = deviceInfo,
           // TODO: Log error
           let deviceInfoJSON = try? deviceInfo.encode2JSONObject() {
            parameters[APIConstants.Keys.data] = deviceInfoJSON
        }

        switch paymentSource {
        case let .cardNumber(number, expDate, cvv):
            let formattedCardData = cardDataFormatter.formatCardData(cardNumber: number, expDate: expDate, cvv: cvv)
            // TODO: Log error
            if let encryptedCardData = try? encryptor.encrypt(string: formattedCardData, publicKey: publicKey) {
                parameters[APIConstants.Keys.cardData] = encryptedCardData
            }
        case let .savedCard(cardId, cvv):
            let formattedCardData = cardDataFormatter.formatCardData(cardId: cardId, cvv: cvv)
            // TODO: Log error
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
