//
//
//  ThreeDSV2AuthorizationRequest.swift
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

struct CresData: Encodable {
    let cres: String
}

public struct ThreeDSV2AuthorizationRequest: RequestOperation {
    
    // MARK: - RequestOperation
    
    public let name: String = "Submit3DSAuthorizationV2"
    
    public let requestMethod: RequestMethod = .post
    
    public var parameters: JSONObject? = nil
    
    public let requestContentType: RequestContentType = .urlEncoded
    
    // MARK: - Init
    
    init(data: CresData) {
        if let json = try? data.encode2JSONObject() {
            parameters = json
        }
    }
}
