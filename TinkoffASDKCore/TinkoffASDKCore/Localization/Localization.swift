//
//
//  Localization.swift
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

struct Localization {
    struct NetworkError {
        static let transportError = localizationString(key: "NetworkError.transportError")
        static let serverError = localizationString(key: "NetworkError.serverError")
        static let emptyBody = localizationString(key: "NetworkError.emptyBody")
    }
}

private extension Localization {
    static func localizationString(key: String) -> String {
        return BundleProvider.bundle.localizedString(forKey: key, value: nil, table: nil)
    }
}

private final class BundleProvider {
    static var bundle: Bundle {
        return Bundle(for: BundleProvider.self)
    }
}
