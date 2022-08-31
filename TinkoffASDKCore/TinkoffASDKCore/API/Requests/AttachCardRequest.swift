//
//
//  AttachCardRequest.swift
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

struct AttachCardRequest: APIRequest {
    typealias Payload = AttachCardPayload
    
    var requestPath: [String] { ["AttachCard"] }
    var httpMethod: HTTPMethod { .post }
    
    private(set) var parameters: HTTPParameters = [:]
    
    private let finishAddCardData: FinishAddCardData
    private let encryptor: RSAEncryptor
    private let cardDataFormatter: CardDataFormatter
    private let publicKey: SecKey
    
    init(finishAddCardData: FinishAddCardData,
         encryptor: RSAEncryptor,
         cardDataFormatter: CardDataFormatter,
         publicKey: SecKey) {
        self.finishAddCardData = finishAddCardData
        self.encryptor = encryptor
        self.cardDataFormatter = cardDataFormatter
        self.publicKey = publicKey
        self.parameters = createParameters(with: finishAddCardData)
    }
}

private extension AttachCardRequest {
    func createParameters(with requestData: FinishAddCardData) -> HTTPParameters {
        var parameters: HTTPParameters = [APIConstants.Keys.requestKey: requestData.requestKey]
        
        let formattedCardData = cardDataFormatter.formatCardData(cardNumber: requestData.cardNumber,
                                                                 expDate: requestData.expDate,
                                                                 cvv: requestData.cvv)
        // TODO: Log error
        if let encryptedCardData = try? encryptor.encrypt(string: formattedCardData, publicKey: publicKey) {
            parameters[APIConstants.Keys.cardData] = encryptedCardData
        }
        
        return parameters
    }
}
