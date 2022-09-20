//
//
//  APIURLBuilder.swift
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

struct APIURLBuilder {
    enum Error: Swift.Error {
        case failedToBuildAPIUrl
    }

    func buildURL(host: String) throws -> URL {
        guard !host.isEmpty else { throw Error.failedToBuildAPIUrl }
        guard let url = URL(string: "https://\(host)") else {
            throw Error.failedToBuildAPIUrl
        }

        return url
    }
}
