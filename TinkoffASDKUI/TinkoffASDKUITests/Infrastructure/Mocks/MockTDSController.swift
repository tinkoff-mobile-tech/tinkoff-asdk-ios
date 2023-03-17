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
