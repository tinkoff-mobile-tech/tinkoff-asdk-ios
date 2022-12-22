//
//  GetTerminalPayMethodsRequest.swift
//  TinkoffASDKCore
//
//  Created by r.akhmadeev on 28.11.2022.
//

import Foundation

struct GetTerminalPayMethodsRequest: AcquiringRequest {
    let baseURL: URL
    let path: String
    let httpMethod: HTTPMethod = .get
    let tokenFormationStrategy: TokenFormationStrategy = .none
    let terminalKeyProvidingStrategy: TerminalKeyProvidingStrategy = .never

    init(baseURL: URL, terminalKey: String) {
        self.baseURL = baseURL
        path = .pathWithQueries(terminalKey: terminalKey)
    }
}

// MARK: - String + Helpers

private extension String {
    static let paySourceKey = "PaySource"
    static let paySourceValue = "SDK"

    // TODO: MIC-7135 Add correct way to handle query parameters in NetworkClient
    static func pathWithQueries(terminalKey: String) -> String {
        "v2/GetTerminalPayMethods?\(Constants.Keys.terminalKey)=\(terminalKey)&\(paySourceKey)=\(paySourceValue)"
    }
}
