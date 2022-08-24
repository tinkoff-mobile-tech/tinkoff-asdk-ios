//
//
//  SampleTokenGenerator.swift
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

final class SampleTokenGenerator: TokenGenerator {
    static let shared = SampleTokenGenerator()

    private init() { }

    func generateToken(parameters: [String: Any], completion: @escaping (String) -> Void) {
        var tokenParams: [String: Any] = [:]

        tokenParams.updateValue(StageTestData.terminalKey, forKey: "TerminalKey")
        tokenParams.updateValue(StageTestData.terminalPassword, forKey: "Password")

        tokenParams.merge(parameters) { (_, new) -> JSONValue in new }

        let tokenSring: String = tokenParams.sorted(by: { (arg1, arg2) -> Bool in
            arg1.key < arg2.key
        }).map { (item) -> String? in
            String(describing: item.value)
        }.compactMap { $0 }.joined()

        completion(tokenSring)
    }
}
