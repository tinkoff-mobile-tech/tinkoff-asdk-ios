//
//
//  ChargePaymentRequest.swift
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

struct ChargePaymentRequest: APIRequest {
    typealias Payload = ChargePaymentPayload
    
    var requestPath: [String] { ["Charge"] }
    var httpMethod: HTTPMethod { .post }
    var baseURL: URL

    var parameters: HTTPParameters {
        // TODO: Log error
        return (try? paymentChargeRequestData.encode2JSONObject(dateEncodingStrategy: .iso8601)) ?? [:]
    }
    
    private let paymentChargeRequestData: PaymentChargeRequestData

    init(paymentChargeRequestData: PaymentChargeRequestData, baseURL: URL) {
        self.paymentChargeRequestData = paymentChargeRequestData
        self.baseURL = baseURL
    }
}
