//
//  GetAddCardStateRequest.swift
//  TinkoffASDKCore
//
//  Created by r.akhmadeev on 18.02.2023.
//

import Foundation

struct GetAddCardStateRequest: AcquiringRequest {
    let baseURL: URL
    let path: String = "v2/GetAddCardState"
    let httpMethod: HTTPMethod = .post
    let parameters: HTTPParameters
    let terminalKeyProvidingStrategy: TerminalKeyProvidingStrategy = .always
    let tokenFormationStrategy: TokenFormationStrategy = .includeAll()

    init(data: GetAddCardStateData, baseURL: URL) {
        self.baseURL = baseURL
        parameters = (try? data.encode2JSONObject()) ?? [:]
    }
}
