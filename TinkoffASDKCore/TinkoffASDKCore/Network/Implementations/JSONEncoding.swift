//
//
//  JSONEncoding.swift
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

struct JSONEncoding: ParametersEncoder {
    
    enum Error: Swift.Error {
        case encodingFailed(error: Swift.Error)
    }
    
    private let options: JSONSerialization.WritingOptions
    
    init(options: JSONSerialization.WritingOptions = []) {
        self.options = options
    }
    
    func encode(_ urlRequest: URLRequest, parameters: HTTPParameters) throws -> URLRequest {
        guard !parameters.isEmpty else { return urlRequest }
        
        do {
            let data = try JSONSerialization.data(withJSONObject: parameters,
                                                  options: options)
            
            var mutableUrlRequest = urlRequest
            mutableUrlRequest.httpBody = data
            
            if mutableUrlRequest.value(forHTTPHeaderField: .contentType) == nil {
                mutableUrlRequest.setValue(.applicationJson, forHTTPHeaderField: .contentType)
            }
            
            return mutableUrlRequest
        } catch {
            throw Error.encodingFailed(error: error)
        }
    }
}

private extension String {
    static let contentType = "Content-Type"
    static let applicationJson = "appplication/json"
}
