//
//
//  DefaultHTTPURLResponseValidator.swift
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

struct DefaultHTTPURLResponseValidator: HTTPURLResponseValidator {
    
    enum Error: Swift.Error {
        case failedStatusCode
    }
    
    private let successStatusCodes = 200...299
    func validate(response: HTTPURLResponse) -> Swift.Result<Void, Swift.Error> {
        if successStatusCodes.contains(response.statusCode) {
            return .success(())
        } else {
            return .failure(Error.failedStatusCode)
        }
    }
}
