//
//  SBPBankAppOpenerMock.swift
//  TinkoffASDKUI-Unit-Tests
//
//  Created by Aleksandr Pravosudov on 20.04.2023.
//

import Foundation
import TinkoffASDKCore
@testable import TinkoffASDKUI

final class SBPBankAppOpenerMock: ISBPBankAppOpener {

    // MARK: - openBankApp

    typealias OpenBankAppArguments = (url: URL, bank: SBPBank, completion: SBPBankAppCheckerOpenBankAppCompletion)

    var openBankAppCallsCount = 0
    var openBankAppReceivedArguments: OpenBankAppArguments?
    var openBankAppReceivedInvocations: [OpenBankAppArguments?] = []
    var openBankAppCompletionClosureInput: Bool?

    func openBankApp(url: URL, _ bank: SBPBank, completion: @escaping SBPBankAppCheckerOpenBankAppCompletion) {
        openBankAppCallsCount += 1
        let arguments = (url, bank, completion)
        openBankAppReceivedArguments = arguments
        openBankAppReceivedInvocations.append(arguments)
        if let openBankAppCompletionClosureInput = openBankAppCompletionClosureInput {
            completion(openBankAppCompletionClosureInput)
        }
    }
}

// MARK: - Resets

extension SBPBankAppOpenerMock {
    func fullReset() {
        openBankAppCallsCount = 0
        openBankAppReceivedArguments = nil
        openBankAppReceivedInvocations = []
        openBankAppCompletionClosureInput = nil
    }
}
