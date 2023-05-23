//
//  SavedCardViewPresenterAssemblyMock.swift
//  TinkoffASDKUI-Unit-Tests
//
//  Created by Aleksandr Pravosudov on 23.05.2023.
//

@testable import TinkoffASDKUI

final class SavedCardViewPresenterAssemblyMock: ISavedCardViewPresenterAssembly {

    // MARK: - build

    var buildCallsCount = 0
    var buildReceivedArguments: ISavedCardViewPresenterOutput?
    var buildReceivedInvocations: [ISavedCardViewPresenterOutput] = []
    var buildReturnValue: ISavedCardViewOutput = SavedCardViewOutputMock()

    func build(output: ISavedCardViewPresenterOutput) -> ISavedCardViewOutput {
        buildCallsCount += 1
        let arguments = (output)
        buildReceivedArguments = arguments
        buildReceivedInvocations.append(arguments)
        return buildReturnValue
    }
}
