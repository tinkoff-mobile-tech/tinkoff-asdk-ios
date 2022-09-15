//
//
//  TestsNetworkRequest.swift
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

@testable import TinkoffASDKCore

struct TestsNetworkRequest: NetworkRequest {
    let path: [String]
    let httpMethod: HTTPMethod
    let parameters: HTTPParameters
    let parametersEncoding: HTTPParametersEncoding
    let headers: HTTPHeaders
    let baseURL: URL

    init(
        path: [String],
        httpMethod: HTTPMethod,
        parameters: HTTPParameters = [:],
        parametersEncoding: HTTPParametersEncoding = .json,
        headers: HTTPHeaders = [:],
        baseURL: URL = URL(string: "https://www.tinkoff.ru")!
    ) {
        self.path = path
        self.httpMethod = httpMethod
        self.parameters = parameters
        self.parametersEncoding = parametersEncoding
        self.headers = headers
        self.baseURL = baseURL
    }
}
