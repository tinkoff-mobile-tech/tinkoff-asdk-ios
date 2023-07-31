//
//  ThreeDSWebFlowControllerMock.swift
//  TinkoffASDKUI-Unit-Tests
//
//  Created by Ivan Glushko on 27.03.2023.
//

import TinkoffASDKCore
@testable import TinkoffASDKUI

final class ThreeDSWebFlowControllerMock: IThreeDSWebFlowController {
    var webFlowDelegate: (any ThreeDSWebFlowDelegate)?

    // MARK: - complete3DSMethod

    typealias Complete3DSMethodArguments = Checking3DSURLData

    var complete3DSMethodThrowableError: Error?
    var complete3DSMethodCallsCount = 0
    var complete3DSMethodReceivedArguments: Complete3DSMethodArguments?
    var complete3DSMethodReceivedInvocations: [Complete3DSMethodArguments?] = []

    func complete3DSMethod(checking3DSURLData: Checking3DSURLData) throws {
        if let error = complete3DSMethodThrowableError {
            throw error
        }
        complete3DSMethodCallsCount += 1
        let arguments = checking3DSURLData
        complete3DSMethodReceivedArguments = arguments
        complete3DSMethodReceivedInvocations.append(arguments)
    }

    // MARK: - confirm3DS

    typealias Confirm3DSArguments = (data: Confirmation3DSData, completion: (ThreeDSWebViewHandlingResult<GetPaymentStatePayload>) -> Void)

    var confirm3DSCallsCount = 0
    var confirm3DSReceivedArguments: Confirm3DSArguments?
    var confirm3DSReceivedInvocations: [Confirm3DSArguments?] = []
    var confirm3DSCompletionClosureInput: ThreeDSWebViewHandlingResult<GetPaymentStatePayload>?

    func confirm3DS(data: Confirmation3DSData, completion: @escaping (ThreeDSWebViewHandlingResult<GetPaymentStatePayload>) -> Void) {
        confirm3DSCallsCount += 1
        let arguments = (data, completion)
        confirm3DSReceivedArguments = arguments
        confirm3DSReceivedInvocations.append(arguments)
        if let confirm3DSCompletionClosureInput = confirm3DSCompletionClosureInput {
            completion(confirm3DSCompletionClosureInput)
        }
    }

    // MARK: - confirm3DSACS

    typealias Confirm3DSACSArguments = (data: Confirmation3DSDataACS, messageVersion: String, completion: (ThreeDSWebViewHandlingResult<GetPaymentStatePayload>) -> Void)

    var confirm3DSACSCallsCount = 0
    var confirm3DSACSReceivedArguments: Confirm3DSACSArguments?
    var confirm3DSACSReceivedInvocations: [Confirm3DSACSArguments?] = []
    var confirm3DSACSCompletionClosureInput: ThreeDSWebViewHandlingResult<GetPaymentStatePayload>?

    func confirm3DSACS(data: Confirmation3DSDataACS, messageVersion: String, completion: @escaping (ThreeDSWebViewHandlingResult<GetPaymentStatePayload>) -> Void) {
        confirm3DSACSCallsCount += 1
        let arguments = (data, messageVersion, completion)
        confirm3DSACSReceivedArguments = arguments
        confirm3DSACSReceivedInvocations.append(arguments)
        if let confirm3DSACSCompletionClosureInput = confirm3DSACSCompletionClosureInput {
            completion(confirm3DSACSCompletionClosureInput)
        }
    }
}

// MARK: - Resets

extension ThreeDSWebFlowControllerMock {
    func fullReset() {
        complete3DSMethodThrowableError = nil
        complete3DSMethodCallsCount = 0
        complete3DSMethodReceivedArguments = nil
        complete3DSMethodReceivedInvocations = []

        confirm3DSCallsCount = 0
        confirm3DSReceivedArguments = nil
        confirm3DSReceivedInvocations = []
        confirm3DSCompletionClosureInput = nil

        confirm3DSACSCallsCount = 0
        confirm3DSACSReceivedArguments = nil
        confirm3DSACSReceivedInvocations = []
        confirm3DSACSCompletionClosureInput = nil
    }
}
