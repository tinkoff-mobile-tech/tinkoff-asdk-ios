//
//
//  Check3DSVersionPayload.swift
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

public struct Check3DSVersionPayload: Equatable {
    public let version: String
    public let tdsServerTransID: String?
    public let threeDSMethodURL: String?
    public let paymentSystem: String?

    public init(
        version: String,
        tdsServerTransID: String?,
        threeDSMethodURL: String?,
        paymentSystem: String?
    ) {
        self.version = version
        self.tdsServerTransID = tdsServerTransID
        self.threeDSMethodURL = threeDSMethodURL
        self.paymentSystem = paymentSystem
    }
}

// MARK: - Check3DSVersionPayload + Decodable

extension Check3DSVersionPayload: Decodable {
    private enum CodingKeys: CodingKey {
        case version
        case tdsServerTransID
        case threeDSMethodURL
        case paymentSystem

        var stringValue: String {
            switch self {
            case .version: return Constants.Keys.version
            case .tdsServerTransID: return Constants.Keys.tdsServerTransID
            case .threeDSMethodURL: return Constants.Keys.threeDSMethodURL
            case .paymentSystem: return Constants.Keys.paymentSystem
            }
        }
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        version = try container.decode(String.self, forKey: .version)
        tdsServerTransID = try container.decodeIfPresent(String.self, forKey: .tdsServerTransID)
        threeDSMethodURL = try container.decodeIfPresent(String.self, forKey: .threeDSMethodURL)
        paymentSystem = try container.decodeIfPresent(String.self, forKey: .paymentSystem)
    }
}

// MARK: - Check3DSVersionPayload + ThreeDSVersion

public extension Check3DSVersionPayload {

    /// Версия 3дс
    ///
    /// Извлеченная по косвенным параметрам из `Check3DSVersionPayload`
    enum ThreeDSVersion {
        /// 1.0.0
        case v1
        /// 2.0.0 ACS
        case v2
        /// 2.1.0 App based
        case appBased
    }

    /// Получить версию 3дс
    func receiveVersion() -> ThreeDSVersion {
        let hasTdsServerTransID = tdsServerTransID != nil
        let hasThreeDSMethodURL = threeDSMethodURL != nil
        let hasPaymentSystem = paymentSystem != nil

        /// Смотрим на наличие необходимых параметров для флоу
        switch (hasTdsServerTransID, hasThreeDSMethodURL, hasPaymentSystem) {
        case (true, true, true): return .appBased
        case (true, true, _): return .v2
        default: return .v1
        }
    }
}
