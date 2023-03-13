//
//
//  GetTinkoffLinkPayload.swift
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

public struct GetTinkoffLinkPayload {
    public let redirectUrl: URL
}

extension GetTinkoffLinkPayload: Decodable {
    private enum CodingKeys: String, CodingKey {
        case params = "Params"
    }

    private enum ParamsCodingKeys: String, CodingKey {
        case redirectUrl = "RedirectUrl"
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let params = try container.nestedContainer(keyedBy: ParamsCodingKeys.self, forKey: .params)
        redirectUrl = try params.decode(URL.self, forKey: .redirectUrl)
    }
}
