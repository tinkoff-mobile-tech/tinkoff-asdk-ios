//
//
//  AcquiringTokenBuilder.swift
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

struct AcquiringTokenBuilder: APITokenBuilder {
    private let password: String
    
    // MARK: - Init
    
    init(password: String) {
        self.password = password
    }
    
    // MARK: - APITokenBuilder
    
    func buildToken(parameters: HTTPParameters) -> String {
        var tokenParameters = parameters
        tokenParameters[APIConstants.Keys.password] = password
        
        let gluedParameterValues = tokenParameters
            .sorted { $0.key < $1.key }
            .map { String(describing: $0.value) }
            .joined()
        
        return gluedParameterValues.sha256()
    }
}
