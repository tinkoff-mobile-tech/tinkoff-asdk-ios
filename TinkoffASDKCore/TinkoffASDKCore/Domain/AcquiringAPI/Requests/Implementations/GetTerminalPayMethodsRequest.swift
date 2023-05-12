//
//  GetTerminalPayMethodsRequest.swift
//  TinkoffASDKCore
//
//  Created by r.akhmadeev on 28.11.2022.
//

import Foundation

struct GetTerminalPayMethodsRequest: AcquiringRequest {
    let baseURL: URL
    let path: String = "v2/GetTerminalPayMethods"
    let httpMethod: HTTPMethod = .get
    let tokenFormationStrategy: TokenFormationStrategy = .none
    let terminalKeyProvidingStrategy: TerminalKeyProvidingStrategy = .never
    let queryItems: [URLQueryItem]

    init(baseURL: URL, terminalKey: String) {
        self.baseURL = baseURL
        queryItems = [
            URLQueryItem(name: Constants.Keys.terminalKey, value: terminalKey),
            URLQueryItem(name: .paySourceKey, value: .paySourceValue),
        ]
    }
}

// MARK: - String + Helpers

private extension String {
    static let paySourceKey = "PaySource"
    static let paySourceValue = "SDK"
}
