//
//
//  GetCardListRequest.swift
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

struct GetCardListRequest: APIRequest, TokenProvidableAPIRequest {
    typealias Payload = [PaymentCard]
    
    var requestPath: [String] { ["GetCardList"] }
    var httpMethod: HTTPMethod { .post }
    var decodeStrategy: APIRequestDecodeStrategy { .clipped }
    
    var parameters: HTTPParameters {
        // TODO: Log error
        return (try? getCardListData.encode2JSONObject()) ?? [:]
    }
    
    private let getCardListData: GetCardListData
    
    init(getCardListData: GetCardListData) {
        self.getCardListData = getCardListData
    }
}
