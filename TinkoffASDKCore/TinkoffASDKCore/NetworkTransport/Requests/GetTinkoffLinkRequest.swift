//
//  GetTinkoffLinkRequest.swift
//  TinkoffASDKCore
//
//  Created by Serebryaniy Grigoriy on 14.04.2022.
//

import Foundation

public struct GetTinkoffLinkRequest: RequestOperation {

    // MARK: - RequestOperation

    public var name: String {
        createRequestName()
    }

    public var requestMethod: RequestMethod = .get

    public var parameters: JSONObject?

    // MARK: - Parameters

    private let paymentId: Int64
    private let version: GetTinkoffPayStatusResponse.Status.Version

    // MARK: - Init

    init(
        paymentId: Int64,
        version: GetTinkoffPayStatusResponse.Status.Version
    ) {
        self.paymentId = paymentId
        self.version = version
    }
}

private extension GetTinkoffLinkRequest {
    func createRequestName() -> String {
        var endpointURL = URL(string: "TinkoffPay/transactions")!
        endpointURL.appendPathComponent("\(paymentId)")
        endpointURL.appendPathComponent("versions")
        endpointURL.appendPathComponent(version.rawValue)
        endpointURL.appendPathComponent("link")
        return endpointURL.absoluteString
    }
}
