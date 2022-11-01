//
//  MockTDSController.swift
//  TinkoffASDKUI-Unit-Tests
//
//  Created by Ivan Glushko on 17.10.2022.
//

import TinkoffASDKCore
@testable import TinkoffASDKUI

final class MockTDSController: ITDSController {

    var completionHandler: TinkoffASDKUI.PaymentCompletionHandler?

    var cancelHandler: (() -> Void)?

    // MARK: - enrichRequestDataWithAuthParams

    struct EnrichRequestDataWithAuthParamsPassedArguments {
        let paymentSystem: String
        let messageVersion: String
        let finishRequestData: TinkoffASDKCore.PaymentFinishRequestData
        let completion: (Result<TinkoffASDKCore.PaymentFinishRequestData, Error>) -> Void
    }

    var enrichRequestDataWithAuthParamsCallCounter = 0
    var enrichRequestDataWithAuthParamsPassedArguments: EnrichRequestDataWithAuthParamsPassedArguments?

    func enrichRequestDataWithAuthParams(
        with paymentSystem: String,
        messageVersion: String,
        finishRequestData: TinkoffASDKCore.PaymentFinishRequestData,
        completion: @escaping (Result<TinkoffASDKCore.PaymentFinishRequestData, Error>) -> Void
    ) {
        enrichRequestDataWithAuthParamsCallCounter += 1
        enrichRequestDataWithAuthParamsPassedArguments = EnrichRequestDataWithAuthParamsPassedArguments(
            paymentSystem: paymentSystem,
            messageVersion: messageVersion,
            finishRequestData: finishRequestData,
            completion: completion
        )
    }

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
