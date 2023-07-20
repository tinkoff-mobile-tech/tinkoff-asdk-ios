//
//  SwitchViewPresenterAssemblyMock.swift
//  TinkoffASDKUI-Unit-Tests
//
//  Created by Aleksandr Pravosudov on 23.05.2023.
//

@testable import TinkoffASDKUI

final class SwitchViewPresenterAssemblyMock: ISwitchViewPresenterAssembly {

    // MARK: - build

    typealias BuildArguments = (title: String, isOn: Bool, actionBlock: SwitchViewPresenterActionBlock?)

    var buildCallsCount = 0
    var buildReceivedArguments: BuildArguments?
    var buildReceivedInvocations: [BuildArguments?] = []
    var buildActionBlockClosureInput: Bool?
    var buildReturnValue = SwitchViewOutputMock()

    func build(title: String, isOn: Bool, actionBlock: SwitchViewPresenterActionBlock?) -> ISwitchViewOutput {
        buildCallsCount += 1
        let arguments = (title, isOn, actionBlock)
        buildReceivedArguments = arguments
        buildReceivedInvocations.append(arguments)
        if let buildActionBlockClosureInput = buildActionBlockClosureInput {
            actionBlock?(buildActionBlockClosureInput)
        }
        return buildReturnValue
    }
}

// MARK: - Resets

extension SwitchViewPresenterAssemblyMock {
    func fullReset() {
        buildCallsCount = 0
        buildReceivedArguments = nil
        buildReceivedInvocations = []
        buildActionBlockClosureInput = nil
    }
}
