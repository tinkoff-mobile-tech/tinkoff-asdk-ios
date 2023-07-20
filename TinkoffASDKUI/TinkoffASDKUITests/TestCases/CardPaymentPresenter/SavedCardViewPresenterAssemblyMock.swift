//
//  SavedCardViewPresenterAssemblyMock.swift
//  TinkoffASDKUI-Unit-Tests
//
//  Created by Aleksandr Pravosudov on 23.05.2023.
//

@testable import TinkoffASDKUI

final class SavedCardViewPresenterAssemblyMock: ISavedCardViewPresenterAssembly {

    // MARK: - build

    typealias BuildArguments = ISavedCardViewPresenterOutput

    var buildCallsCount = 0
    var buildReceivedArguments: BuildArguments?
    var buildReceivedInvocations: [BuildArguments?] = []
    var buildReturnValue = SavedCardViewOutputMock()

    func build(output: ISavedCardViewPresenterOutput) -> ISavedCardViewOutput {
        buildCallsCount += 1
        let arguments = output
        buildReceivedArguments = arguments
        buildReceivedInvocations.append(arguments)
        return buildReturnValue
    }
}

// MARK: - Resets

extension SavedCardViewPresenterAssemblyMock {
    func fullReset() {
        buildCallsCount = 0
        buildReceivedArguments = nil
        buildReceivedInvocations = []
    }
}
