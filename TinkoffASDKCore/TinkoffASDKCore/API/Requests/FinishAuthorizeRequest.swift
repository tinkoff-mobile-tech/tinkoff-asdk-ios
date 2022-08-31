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
    
    private(set) var parameters: HTTPParameters = [:]
    
    private let paymentFinishRequestData: PaymentFinishRequestData
    private let encryptor: RSAEncryptor
    private let cardDataFormatter: CardDataFormatter
    private let publicKey: SecKey
    
    init(paymentFinishRequestData: PaymentFinishRequestData,
         encryptor: RSAEncryptor,
         cardDataFormatter: CardDataFormatter,
         publicKey: SecKey) {
        self.paymentFinishRequestData = paymentFinishRequestData
        self.encryptor = encryptor
        self.cardDataFormatter = cardDataFormatter
        self.publicKey = publicKey
        self.parameters = createParameters(with: paymentFinishRequestData)
    }
}

private extension FinishAuthorizeRequest {
    func createParameters(with requestData: PaymentFinishRequestData) -> HTTPParameters {
        var parameters: HTTPParameters = [APIConstants.Keys.paymentId: requestData.paymentId]
        if let sendEmail = requestData.sendEmail {
            parameters[APIConstants.Keys.sendEmail] = sendEmail
        }
        if let infoEmail = requestData.infoEmail {
            parameters[APIConstants.Keys.infoEmail] = infoEmail
        }
        if let ipAddress = requestData.ipAddress {
            parameters[APIConstants.Keys.ipAddress] = ipAddress
        }
        if let deviceInfo = requestData.deviceInfo,
           // TODO: Log error
           let deviceInfoJSON = try? deviceInfo.encode2JSONObject() {
            parameters[APIConstants.Keys.data] = deviceInfoJSON
        }
        
        switch requestData.paymentSource {
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
