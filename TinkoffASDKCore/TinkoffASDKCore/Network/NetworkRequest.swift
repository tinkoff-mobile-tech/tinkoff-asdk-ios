//
//
//  NetworkRequest.swift
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

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
}

enum HTTPParametersEncoding {
    case json
}

typealias HTTPParameters = [String: Any]
typealias HTTPHeaders = [String: String]

protocol NetworkRequest {
    var path: [String] { get }
    var httpMethod: HTTPMethod { get }
    var parameters: HTTPParameters { get }
    var parametersEncoding: HTTPParametersEncoding { get }
    var headers: HTTPHeaders { get }
    var baseURL: URL { get }
}

extension NetworkRequest {
    var parameters: HTTPParameters { [:] }
    var parametersEncoding: HTTPParametersEncoding { .json }
    var headers: HTTPHeaders { [:] }
}
