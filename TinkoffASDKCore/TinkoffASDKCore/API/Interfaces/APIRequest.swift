//
//
//  APIRequest.swift
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

protocol APIRequest: NetworkRequest {
    var requestPath: [String] { get }
    var apiVersion: APIVersion { get }
    var tokenParams: [String: Any] { get }
    var notTokenParameterKeys: Set<String> { get }
    var commonNotTokenParameters: Set<String> { get }
}

extension APIRequest {
    var apiVersion: APIVersion {
        .v2
    }
    
    var path: [String] {
        return [apiVersion.path] + requestPath
    }
    
    var tokenParams: [String: Any] {
        parameters.filter { !notTokenParameterKeys.union(commonNotTokenParameters).contains($0.key) }
    }
    
    var notTokenParameterKeys: Set<String> {
        []
    }
    
    var commonNotTokenParameters: Set<String> {
        return ["DATA", "Receipt", "Receipts", "Shops"]
    }
}
