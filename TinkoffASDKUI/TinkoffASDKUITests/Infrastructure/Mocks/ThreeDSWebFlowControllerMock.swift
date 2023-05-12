//
//  ThreeDSWebFlowControllerMock.swift
//  TinkoffASDKUI-Unit-Tests
//
//  Created by Ivan Glushko on 27.03.2023.
//

import TinkoffASDKCore
@testable import TinkoffASDKUI

final class ThreeDSWebFlowControllerMock: IThreeDSWebFlowController {

    var underlyingWebFlowDelegate: ThreeDSWebFlowDelegate?
    var webFlowDelegateCallsCount = 0
    var webFlowDelegateSetterCounter = 0

    var webFlowDelegate: ThreeDSWebFlowDelegate? {
        get {
            webFlowDelegateCallsCount += 1
            return underlyingWebFlowDelegate
        }
        set {
            webFlowDelegateSetterCounter += 1
        }
    }

    // MARK: - complete3DSMethod

    var complete3DSMethodThrowableError: Error?
    var complete3DSMethodCallsCount = 0
    var complete3DSMethodReceivedArguments: Checking3DSURLData?
    var complete3DSMethodReceivedInvocations: [Checking3DSURLData] = []

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
    var confirm3DSReceivedInvocations: [Confirm3DSArguments] = []
    var confirm3DSCompletionStub: ThreeDSWebViewHandlingResult<GetPaymentStatePayload>?

    func confirm3DS(data: Confirmation3DSData, completion: @escaping (ThreeDSWebViewHandlingResult<GetPaymentStatePayload>) -> Void) {
        confirm3DSCallsCount += 1
        let arguments = (data, completion)
        confirm3DSReceivedArguments = arguments
        confirm3DSReceivedInvocations.append(arguments)
        if let confirm3DSCompletionStub = confirm3DSCompletionStub {
            completion(confirm3DSCompletionStub)
        }
    }

    // MARK: - confirm3DSACS

    typealias Confirm3DSACSArguments = (data: Confirmation3DSDataACS, messageVersion: String, completion: (ThreeDSWebViewHandlingResult<GetPaymentStatePayload>) -> Void)

    var confirm3DSACSCallsCount = 0
    var confirm3DSACSReceivedArguments: Confirm3DSACSArguments?
    var confirm3DSACSReceivedInvocations: [Confirm3DSACSArguments] = []
    var confirm3DSACSCompletionInput: ThreeDSWebViewHandlingResult<GetPaymentStatePayload>?

    func confirm3DSACS(data: Confirmation3DSDataACS, messageVersion: String, completion: @escaping (ThreeDSWebViewHandlingResult<GetPaymentStatePayload>) -> Void) {
        confirm3DSACSCallsCount += 1
        let arguments = (data, messageVersion, completion)
        confirm3DSACSReceivedArguments = arguments
        confirm3DSACSReceivedInvocations.append(arguments)
        if let confirm3DSACSCompletionInput = confirm3DSACSCompletionInput {
            completion(confirm3DSACSCompletionInput)
        }
    }
}
