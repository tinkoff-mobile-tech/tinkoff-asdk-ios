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
        data: GetTinkoffLinkData,
        baseURL: URL
    ) {
        self.baseURL = baseURL
        path = "v2/TinkoffPay/transactions/\(data.paymentId)/versions/\(data.version)/link"
    }
}
