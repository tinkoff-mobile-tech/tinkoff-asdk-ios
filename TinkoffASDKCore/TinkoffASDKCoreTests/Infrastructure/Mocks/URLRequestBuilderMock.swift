//
//  URLRequestBuilderMock.swift
//  TinkoffASDKCore-Unit-Tests
//
//  Created by r.akhmadeev on 10.10.2022.
//

import Foundation
@testable import TinkoffASDKCore

final class URLRequestBuilderMock: IURLRequestBuilder {

    // MARK: - build

    typealias BuildArguments = NetworkRequest

    var buildThrowableError: Error?
    var buildCallsCount = 0
    var buildReceivedArguments: BuildArguments?
    var buildReceivedInvocations: [BuildArguments?] = []
    var buildReturnValue: URLRequest = .init(url: .doesNotMatter)

    func build(request: NetworkRequest) throws -> URLRequest {
        if let error = buildThrowableError {
            throw error
        }
        buildCallsCount += 1
        let arguments = request
        buildReceivedArguments = arguments
        buildReceivedInvocations.append(arguments)
        return buildReturnValue
    }
}

// MARK: - Resets

extension URLRequestBuilderMock {
    func fullReset() {
        buildThrowableError = nil
        buildCallsCount = 0
        buildReceivedArguments = nil
        buildReceivedInvocations = []
    }
}
