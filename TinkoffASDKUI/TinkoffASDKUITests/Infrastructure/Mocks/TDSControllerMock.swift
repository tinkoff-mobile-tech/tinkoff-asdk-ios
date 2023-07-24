//
//  TDSControllerMock.swift
//  TinkoffASDKUI-Unit-Tests
//
//  Created by Ivan Glushko on 17.10.2022.
//

import TinkoffASDKCore
@testable import TinkoffASDKUI

final class TDSControllerMock: ITDSController {
    var completionHandler: PaymentCompletionHandler?
    var cancelHandler: (() -> Void)?

    // MARK: - startAppBasedFlow

    typealias StartAppBasedFlowArguments = (check3dsPayload: Check3DSVersionPayload, completion: (Result<ThreeDSDeviceInfo, Error>) -> Void)

    var startAppBasedFlowCallsCount = 0
    var startAppBasedFlowReceivedArguments: StartAppBasedFlowArguments?
    var startAppBasedFlowReceivedInvocations: [StartAppBasedFlowArguments?] = []
    var startAppBasedFlowCompletionClosureInput: Result<ThreeDSDeviceInfo, Error>?

    func startAppBasedFlow(check3dsPayload: Check3DSVersionPayload, completion: @escaping (Result<ThreeDSDeviceInfo, Error>) -> Void) {
        startAppBasedFlowCallsCount += 1
        let arguments = (check3dsPayload, completion)
        startAppBasedFlowReceivedArguments = arguments
        startAppBasedFlowReceivedInvocations.append(arguments)
        if let startAppBasedFlowCompletionClosureInput = startAppBasedFlowCompletionClosureInput {
            completion(startAppBasedFlowCompletionClosureInput)
        }
    }

    // MARK: - doChallenge

    typealias DoChallengeArguments = Confirmation3DS2AppBasedData

    var doChallengeCallsCount = 0
    var doChallengeReceivedArguments: DoChallengeArguments?
    var doChallengeReceivedInvocations: [DoChallengeArguments?] = []

    func doChallenge(with appBasedData: Confirmation3DS2AppBasedData) {
        doChallengeCallsCount += 1
        let arguments = appBasedData
        doChallengeReceivedArguments = arguments
        doChallengeReceivedInvocations.append(arguments)
    }

    // MARK: - stop

    var stopCallsCount = 0

    func stop() {
        stopCallsCount += 1
    }
}

// MARK: - Resets

extension TDSControllerMock {
    func fullReset() {
        startAppBasedFlowCallsCount = 0
        startAppBasedFlowReceivedArguments = nil
        startAppBasedFlowReceivedInvocations = []
        startAppBasedFlowCompletionClosureInput = nil

        doChallengeCallsCount = 0
        doChallengeReceivedArguments = nil
        doChallengeReceivedInvocations = []

        stopCallsCount = 0
    }
}
