//
//  AcquiringRequestStub.swift
//  TinkoffASDKCore-Unit-Tests
//
//  Created by r.akhmadeev on 24.10.2022.
//

import Foundation
@testable import TinkoffASDKCore

struct AcquiringRequestStub: AcquiringRequest {
    let baseURL: URL
    let path: String
    let httpMethod: HTTPMethod
    let headers: HTTPHeaders
    let parameters: HTTPParameters
    let tokenFormationStrategy: TokenFormationStrategy
    let decodingStrategy: AcquiringDecodingStrategy

    init(
        baseURL: URL = .doesNotMatter,
        path: String = "doesNotMatter",
        httpMethod: HTTPMethod = .get,
        headers: HTTPHeaders = [:],
        parameters: HTTPParameters = [:],
        tokenFormationStrategy: TokenFormationStrategy = .none,
        decodingStrategy: AcquiringDecodingStrategy = .standard
    ) {
        self.baseURL = baseURL
        self.path = path
        self.httpMethod = httpMethod
        self.headers = headers
        self.parameters = parameters
        self.tokenFormationStrategy = tokenFormationStrategy
        self.decodingStrategy = decodingStrategy
    }
}

// MARK: - Equatable

extension AcquiringRequestStub: Equatable {
    static func == (lhs: AcquiringRequestStub, rhs: AcquiringRequestStub) -> Bool {
        lhs.baseURL == rhs.baseURL
            && lhs.path == rhs.path
            && lhs.httpMethod == rhs.httpMethod
            && lhs.headers == rhs.headers
            && lhs.parameters.isEqual(to: rhs.parameters)
            && lhs.tokenFormationStrategy == rhs.tokenFormationStrategy
            && lhs.decodingStrategy == rhs.decodingStrategy
    }
}

// MARK: - Dictionary + Utils

private extension Dictionary where Value == Any {
    func isEqual(to other: [Key: Value]) -> Bool {
        NSDictionary(dictionary: self).isEqual(to: other)
    }
}
