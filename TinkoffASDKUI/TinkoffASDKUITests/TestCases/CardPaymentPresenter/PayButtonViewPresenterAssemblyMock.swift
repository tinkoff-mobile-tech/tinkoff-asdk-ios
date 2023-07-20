//
//  PayButtonViewPresenterAssemblyMock.swift
//  TinkoffASDKUI-Unit-Tests
//
//  Created by Aleksandr Pravosudov on 23.05.2023.
//

@testable import TinkoffASDKUI

final class PayButtonViewPresenterAssemblyMock: IPayButtonViewPresenterAssembly {

    // MARK: - build

    typealias BuildArguments = (presentationState: PayButtonViewPresentationState, output: IPayButtonViewPresenterOutput?)

    var buildCallsCount = 0
    var buildReceivedArguments: BuildArguments?
    var buildReceivedInvocations: [BuildArguments?] = []
    var buildReturnValue = PayButtonViewOutputMock()

    func build(presentationState: PayButtonViewPresentationState, output: IPayButtonViewPresenterOutput?) -> IPayButtonViewOutput {
        buildCallsCount += 1
        let arguments = (presentationState, output)
        buildReceivedArguments = arguments
        buildReceivedInvocations.append(arguments)
        return buildReturnValue
    }
}

// MARK: - Resets

extension PayButtonViewPresenterAssemblyMock {
    func fullReset() {
        buildCallsCount = 0
        buildReceivedArguments = nil
        buildReceivedInvocations = []
    }
}
