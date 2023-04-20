//
//  SBPBanksServiceMock.swift
//  TinkoffASDKUI-Unit-Tests
//
//  Created by Aleksandr Pravosudov on 20.04.2023.
//

import TinkoffASDKCore
@testable import TinkoffASDKUI

final class SBPBanksServiceMock: ISBPBanksService {

    // MARK: - loadBanks

    var loadBanksCallsCount = 0
    var loadBanksReceivedArguments: SBPBanksServiceLoadBanksCompletion?
    var loadBanksReceivedInvocations: [SBPBanksServiceLoadBanksCompletion] = []
    var loadBanksCompletionClosureInput: Result<[SBPBank], Error>?

    func loadBanks(completion: @escaping SBPBanksServiceLoadBanksCompletion) {
        loadBanksCallsCount += 1
        let arguments = completion
        loadBanksReceivedArguments = arguments
        loadBanksReceivedInvocations.append(arguments)
        if let loadBanksCompletionClosureInput = loadBanksCompletionClosureInput {
            completion(loadBanksCompletionClosureInput)
        }
    }
}
