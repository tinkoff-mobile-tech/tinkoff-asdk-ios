//
//  GetTinkoffLinkRequest.swift
//  TinkoffASDKCore
//
//  Created by Serebryaniy Grigoriy on 14.04.2022.
//

import Foundation

struct GetTinkoffLinkRequest: AcquiringRequest {
    let baseURL: URL
    let path: String
    let httpMethod: HTTPMethod = .get
    let terminalKeyProvidingStrategy: TerminalKeyProvidingStrategy = .never
    let tokenFormationStrategy: TokenFormationStrategy = .none

    // MARK: - Init

    init(
        paymentId: String,
        version: GetTinkoffPayStatusResponse.Status.Version,
        baseURL: URL
    ) {
        self.baseURL = baseURL
        path = .path(paymentId: paymentId, version: version)
    }
}

// MARK: - String + Helpers

private extension String {
    static func path(paymentId: String, version: GetTinkoffPayStatusResponse.Status.Version) -> String {
        "v2/TinkoffPay/transactions/\(paymentId)/versions/\(version.rawValue)/link"
    }
}
