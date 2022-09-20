//
//
//  GetStaticQrRequest.swift
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

struct GetStaticQrRequest: APIRequest {
    typealias Payload = GetStaticQrPayload

    var requestPath: [String] { ["GetStaticQr"] }
    var httpMethod: HTTPMethod { .post }
    var baseURL: URL

    var parameters: HTTPParameters {
        return [APIConstants.Keys.dataType: sourceType.rawValue]
    }

    private let sourceType: PaymentInvoiceSBPSourceType

    init(sourceType: PaymentInvoiceSBPSourceType, baseURL: URL) {
        self.sourceType = sourceType
        self.baseURL = baseURL
    }
}
