//
//  AcquiringLocalizable.swift
//  TinkoffASDKUI
//
//  Copyright (c) 2020 Tinkoff Bank
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

protocol AcquiringLocalize: class {
    func localize(_ string: String) -> String

    func setup(lang: String?, table name: String?, bundle: Bundle?)
}

class AcqLoc: AcquiringLocalize {
    static let instance: AcquiringLocalize = AcqLoc()

    private var tableName: String?
    private var bundle: Bundle!

    init() {}

    func setup(lang: String? = nil, table name: String? = nil, bundle: Bundle?) {
        tableName = name
        self.bundle = bundle ?? .asdkUIResources
    }

    func localize(_ string: String) -> String {
        return NSLocalizedString(string, tableName: tableName, bundle: bundle, comment: string)
    }
}
