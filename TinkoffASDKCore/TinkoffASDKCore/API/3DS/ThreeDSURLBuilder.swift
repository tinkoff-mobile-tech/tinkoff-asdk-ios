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

    enum Three3DSURLType: String {
        case threeDSCheckNotificationURL = "Complete3DSMethodv2"
        case confirmation3DSTerminationURL = "Submit3DSAuthorization"
        case confirmation3DSTerminationV2URL = "Submit3DSAuthorizationV2"
    }

    // MARK: Dependencies

    private let baseURLProvider: BaseURLProvider

    // MARK: Init

    init(baseURLProvider: BaseURLProvider) {
        self.baseURLProvider = baseURLProvider
    }

    // MARK: URL Building

    func buildURL(type: Three3DSURLType) -> URL {
        baseURLProvider.baseURL
            .appendingPathComponent(type.apiVersion.path)
            .appendingPathComponent(type.rawValue)
    }
}

// MARK: Helpers

private extension ThreeDSURLBuilder.Three3DSURLType {
    var apiVersion: APIVersion {
        switch self {
        case .threeDSCheckNotificationURL, .confirmation3DSTerminationV2URL:
            return .v2
        case .confirmation3DSTerminationURL:
            return .v1
        }
    }
}
