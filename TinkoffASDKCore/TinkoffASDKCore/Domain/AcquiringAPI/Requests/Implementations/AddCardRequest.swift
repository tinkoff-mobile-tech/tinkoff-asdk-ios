//
//
//  AddCardRequest.swift
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

struct AddCardRequest: AcquiringRequest {
    let baseURL: URL
    let path: String = "v2/AddCard"
    let httpMethod: HTTPMethod = .post
    let parameters: HTTPParameters
    let tokenFormationStrategy: TokenFormationStrategy = .includingAll

    init(initAddCardData: AddCardData, baseURL: URL) {
        self.baseURL = baseURL
        parameters = (try? initAddCardData.encode2JSONObject()) ?? [:]
    }
}
