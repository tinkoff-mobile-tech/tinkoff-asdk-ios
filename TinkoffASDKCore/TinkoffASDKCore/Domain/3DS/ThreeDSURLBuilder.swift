//
//
//  3DSURLBuilder.swift
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

struct ThreeDSURLBuilder {
    // MARK: Three3DSURLType

    struct URLType: RawRepresentable {
        static let threeDSCheckNotificationURL = URLType(rawValue: "v2/Complete3DSMethodv2")
        static let confirmation3DSTerminationURL = URLType(rawValue: "rest/Submit3DSAuthorization")
        static let confirmation3DSTerminationV2URL = URLType(rawValue: "v2/Submit3DSAuthorizationV2")

        let rawValue: String
    }

    // MARK: Dependencies

    private let urlProvider: IURLProvider

    // MARK: Init

    init(urlProvider: IURLProvider) {
        self.urlProvider = urlProvider
    }

    // MARK: URL Building

    func buildURL(type: URLType) -> URL {
        urlProvider.url.appendingPathComponent(type.rawValue)
    }
}
