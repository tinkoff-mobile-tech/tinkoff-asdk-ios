//
//  ThreeDSURLRequestBuilderMock.swift
//  TinkoffASDKCore-Unit-Tests
//
//  Created by Никита Васильев on 31.07.2023.
//

import Foundation
@testable import TinkoffASDKCore

final class ThreeDSURLRequestBuilderMock: IThreeDSURLRequestBuilder {

    // MARK: - buildConfirmation3DSRequestACS

    typealias BuildConfirmation3DSRequestACSArguments = (requestData: Confirmation3DSDataACS, version: String)

    var buildConfirmation3DSRequestACSThrowableError: Error?
    var buildConfirmation3DSRequestACSCallsCount = 0
    var buildConfirmation3DSRequestACSReceivedArguments: BuildConfirmation3DSRequestACSArguments?
    var buildConfirmation3DSRequestACSReceivedInvocations: [BuildConfirmation3DSRequestACSArguments?] = []
    var buildConfirmation3DSRequestACSReturnValue: URLRequest!

    func buildConfirmation3DSRequestACS(requestData: Confirmation3DSDataACS, version: String) throws -> URLRequest {
        if let error = buildConfirmation3DSRequestACSThrowableError {
            throw error
        }
        buildConfirmation3DSRequestACSCallsCount += 1
        let arguments = (requestData, version)
        buildConfirmation3DSRequestACSReceivedArguments = arguments
        buildConfirmation3DSRequestACSReceivedInvocations.append(arguments)
        return buildConfirmation3DSRequestACSReturnValue
    }

    // MARK: - buildConfirmation3DSRequest

    typealias BuildConfirmation3DSRequestArguments = Confirmation3DSData

    var buildConfirmation3DSRequestThrowableError: Error?
    var buildConfirmation3DSRequestCallsCount = 0
    var buildConfirmation3DSRequestReceivedArguments: BuildConfirmation3DSRequestArguments?
    var buildConfirmation3DSRequestReceivedInvocations: [BuildConfirmation3DSRequestArguments?] = []
    var buildConfirmation3DSRequestReturnValue: URLRequest!

    func buildConfirmation3DSRequest(requestData: Confirmation3DSData) throws -> URLRequest {
        if let error = buildConfirmation3DSRequestThrowableError {
            throw error
        }
        buildConfirmation3DSRequestCallsCount += 1
        let arguments = requestData
        buildConfirmation3DSRequestReceivedArguments = arguments
        buildConfirmation3DSRequestReceivedInvocations.append(arguments)
        return buildConfirmation3DSRequestReturnValue
    }

    // MARK: - build3DSCheckURLRequest

    typealias Build3DSCheckURLRequestArguments = Checking3DSURLData

    var build3DSCheckURLRequestThrowableError: Error?
    var build3DSCheckURLRequestCallsCount = 0
    var build3DSCheckURLRequestReceivedArguments: Build3DSCheckURLRequestArguments?
    var build3DSCheckURLRequestReceivedInvocations: [Build3DSCheckURLRequestArguments?] = []
    var build3DSCheckURLRequestReturnValue: URLRequest!

    func build3DSCheckURLRequest(requestData: Checking3DSURLData) throws -> URLRequest {
        if let error = build3DSCheckURLRequestThrowableError {
            throw error
        }
        build3DSCheckURLRequestCallsCount += 1
        let arguments = requestData
        build3DSCheckURLRequestReceivedArguments = arguments
        build3DSCheckURLRequestReceivedInvocations.append(arguments)
        return build3DSCheckURLRequestReturnValue
    }
}

// MARK: - Resets

extension ThreeDSURLRequestBuilderMock {
    func fullReset() {
        buildConfirmation3DSRequestACSThrowableError = nil
        buildConfirmation3DSRequestACSCallsCount = 0
        buildConfirmation3DSRequestACSReceivedArguments = nil
        buildConfirmation3DSRequestACSReceivedInvocations = []

        buildConfirmation3DSRequestThrowableError = nil
        buildConfirmation3DSRequestCallsCount = 0
        buildConfirmation3DSRequestReceivedArguments = nil
        buildConfirmation3DSRequestReceivedInvocations = []

        build3DSCheckURLRequestThrowableError = nil
        build3DSCheckURLRequestCallsCount = 0
        build3DSCheckURLRequestReceivedArguments = nil
        build3DSCheckURLRequestReceivedInvocations = []
    }
}
