//
//
//  HTTPURLResponseValidator.swift
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

protocol IHTTPURLResponseValidator {
    func validate(response: HTTPURLResponse) throws
}

struct HTTPURLResponseValidator: IHTTPURLResponseValidator {
    // MARK: Error

    private struct Error: LocalizedError, CustomNSError {
        let statusCode: Int

        var errorDescription: String? {
            "\(Loc.NetworkError.serverError): \(statusCode)"
        }
    }

    // MARK: Dependencies

    private let successStatusCodes: ClosedRange<Int>

    // MARK: Init

    init(successStatusCodes: ClosedRange<Int> = 200 ... 299) {
        self.successStatusCodes = successStatusCodes
    }

    // MARK: IHTTPURLResponseValidator

    func validate(response: HTTPURLResponse) throws {
        guard successStatusCodes.contains(response.statusCode) else {
            throw Error(statusCode: response.statusCode)
        }
    }
}
