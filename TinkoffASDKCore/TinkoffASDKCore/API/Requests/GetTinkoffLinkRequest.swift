//
//  GetTinkoffLinkRequest.swift
//  TinkoffASDKCore
//
//  Created by Serebryaniy Grigoriy on 14.04.2022.
//

import Foundation

struct GetTinkoffLinkRequest: APIRequest {
    typealias Payload = GetTinkoffLinkPayload
    
    var requestPath: [String] { [self.createRequestName()] }
    var httpMethod: HTTPMethod { .get }

    // MARK: - Parameters
    
    private let paymentId: PaymentId
    private let version: GetTinkoffPayStatusResponse.Status.Version
    
    // MARK: - Init
    
    public init(paymentId: PaymentId,
                version: GetTinkoffPayStatusResponse.Status.Version) {
        self.paymentId = paymentId
        self.version = version
    }
}

private extension GetTinkoffLinkRequest {
    func createRequestName() -> String {
        var endpointURL = URL(string: "TinkoffPay/transactions")!
        endpointURL.appendPathComponent(paymentId)
        endpointURL.appendPathComponent("versions")
        endpointURL.appendPathComponent(version.rawValue)
        endpointURL.appendPathComponent("link")
        return endpointURL.absoluteString
    }
}
