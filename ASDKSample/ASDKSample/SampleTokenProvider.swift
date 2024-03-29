//
//
//  SampleTokenProvider.swift
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
import TinkoffASDKCore

final class SampleTokenProvider: ITokenProvider {
    private let password: String

    init(password: String) {
        self.password = password
    }

    func provideToken(
        forRequestParameters parameters: [String: String],
        completion: @escaping (Result<String, Error>) -> Void
    ) {
        let sourceString = parameters
            .merging([.password: password]) { $1 }
            .sorted { $0.key < $1.key }
            .map(\.value)
            .joined()

        let hashingResult = Result {
            try SHA256.hash(from: sourceString)
        }

        completion(hashingResult)
    }
}

// MARK: - Constants

private extension String {
    static let password = "Password"
}
