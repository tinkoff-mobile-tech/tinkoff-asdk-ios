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

struct Check3DSVersionRequest: APIRequest, TokenProvidableAPIRequest {
    typealias Payload = Check3DSVersionPayload
    
    var requestPath: [String] { ["Check3dsVersion"] }
    var httpMethod: HTTPMethod { .post }
    
    private(set) var parameters: HTTPParameters = [:]
    
    private let check3DSRequestData: Check3DSRequestData
    private let encryptor: RSAEncryptor
    private let cardDataFormatter: CardDataFormatter
    private let publicKey: SecKey
    
    init(check3DSRequestData: Check3DSRequestData,
         encryptor: RSAEncryptor,
         cardDataFormatter: CardDataFormatter,
         publicKey: SecKey) {
        self.check3DSRequestData = check3DSRequestData
        self.encryptor = encryptor
        self.cardDataFormatter = cardDataFormatter
        self.publicKey = publicKey
        self.parameters = createParameters(with: check3DSRequestData)
    }
}

private extension Check3DSVersionRequest {
    func createParameters(with requestData: Check3DSRequestData) -> HTTPParameters {
        var parameters: HTTPParameters = [APIConstants.Keys.paymentId: requestData.paymentId]
        
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

