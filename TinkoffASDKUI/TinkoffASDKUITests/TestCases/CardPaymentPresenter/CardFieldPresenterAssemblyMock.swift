//
//  CardFieldPresenterAssemblyMock.swift
//  TinkoffASDKUI
//
//  Created by Aleksandr Pravosudov on 22.05.2023.
//

@testable import TinkoffASDKUI

final class CardFieldPresenterAssemblyMock: ICardFieldPresenterAssembly {

    // MARK: - build

    typealias BuildArguments = (output: ICardFieldOutput?, isScanButtonNeeded: Bool)

    var buildCallsCount = 0
    var buildReceivedArguments: BuildArguments?
    var buildReceivedInvocations: [BuildArguments?] = []
    var buildReturnValue = CardFieldViewOutputMock()

    func build(output: ICardFieldOutput?, isScanButtonNeeded: Bool) -> ICardFieldViewOutput {
        buildCallsCount += 1
        let arguments = (output, isScanButtonNeeded)
        buildReceivedArguments = arguments
        buildReceivedInvocations.append(arguments)
        return buildReturnValue
    }
}

// MARK: - Resets

extension CardFieldPresenterAssemblyMock {
    func fullReset() {
        buildCallsCount = 0
        buildReceivedArguments = nil
        buildReceivedInvocations = []
    }
}
