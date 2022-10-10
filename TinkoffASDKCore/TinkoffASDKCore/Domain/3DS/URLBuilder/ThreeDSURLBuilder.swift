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

struct ThreeDSURLType: RawRepresentable {
    static let threeDSCheckNotificationURL = ThreeDSURLType(rawValue: "v2/Complete3DSMethodv2")
    static let confirmation3DSTerminationURL = ThreeDSURLType(rawValue: "rest/Submit3DSAuthorization")
    static let confirmation3DSTerminationV2URL = ThreeDSURLType(rawValue: "v2/Submit3DSAuthorizationV2")

    let rawValue: String
}

protocol IThreeDSURLBuilder {
    func url(ofType type: ThreeDSURLType) -> URL
}

final class ThreeDSURLBuilder: IThreeDSURLBuilder {
    // MARK: Dependencies

    private let baseURLProvider: IURLProvider

    // MARK: Init

    init(baseURLProvider: IURLProvider) {
        self.baseURLProvider = baseURLProvider
    }

    // MARK: URL Building

    func url(ofType type: ThreeDSURLType) -> URL {
        baseURLProvider.url.appendingPathComponent(type.rawValue)
    }
}
