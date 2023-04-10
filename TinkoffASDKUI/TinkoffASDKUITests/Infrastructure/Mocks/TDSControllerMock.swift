//
//  TDSControllerMock.swift
//  TinkoffASDKUI-Unit-Tests
//
//  Created by Ivan Glushko on 17.10.2022.
//

import TinkoffASDKCore
@testable import TinkoffASDKUI

final class TDSControllerMock: ITDSController {
    // MARK: - startAppBasedFlow

    typealias StartAppBasedFlowArguments = (check3dsPayload: Check3DSVersionPayload, completion: (Result<ThreeDSDeviceInfo, Error>) -> Void)

    var startAppBasedFlowCallsCount = 0
    var startAppBasedFlowReceivedArguments: StartAppBasedFlowArguments?
    var startAppBasedFlowReceivedInvocations: [StartAppBasedFlowArguments] = []
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

    // MARK: stop

    var stopCallsCount = 0

    func stop() {
        stopCallsCount += 1
    }

    // MARK: cancelHandler

    var completionHandler: TinkoffASDKUI.PaymentCompletionHandler?

    var cancelHandler: (() -> Void)?

    // MARK: - doChallenge

    struct DoChallengePassedArguments {
        let appBasedData: TinkoffASDKCore.Confirmation3DS2AppBasedData
    }

    var doChallengeCallCounter = 0
    var doChallengePassedArguments: DoChallengePassedArguments?

    func doChallenge(
        with appBasedData: TinkoffASDKCore.Confirmation3DS2AppBasedData
    ) {
        doChallengeCallCounter += 1
        doChallengePassedArguments = DoChallengePassedArguments(appBasedData: appBasedData)
    }
}
