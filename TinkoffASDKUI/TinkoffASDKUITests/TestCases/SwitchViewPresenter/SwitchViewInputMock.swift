//
//  SwitchViewInputMock.swift
//  TinkoffASDKUI-Unit-Tests
//
//  Created by Aleksandr Pravosudov on 30.05.2023.
//

@testable import TinkoffASDKUI

final class SwitchViewInputMock: ISwitchViewInput {

    // MARK: - setNameLabel

    typealias SetNameLabelArguments = String

    var setNameLabelCallsCount = 0
    var setNameLabelReceivedArguments: SetNameLabelArguments?
    var setNameLabelReceivedInvocations: [SetNameLabelArguments?] = []

    func setNameLabel(text: String?) {
        setNameLabelCallsCount += 1
        let arguments = text
        setNameLabelReceivedArguments = arguments
        setNameLabelReceivedInvocations.append(arguments)
    }

    // MARK: - setSwitchButtonState

    typealias SetSwitchButtonStateArguments = Bool

    var setSwitchButtonStateCallsCount = 0
    var setSwitchButtonStateReceivedArguments: SetSwitchButtonStateArguments?
    var setSwitchButtonStateReceivedInvocations: [SetSwitchButtonStateArguments?] = []

    func setSwitchButtonState(isOn: Bool) {
        setSwitchButtonStateCallsCount += 1
        let arguments = isOn
        setSwitchButtonStateReceivedArguments = arguments
        setSwitchButtonStateReceivedInvocations.append(arguments)
    }
}

// MARK: - Resets

extension SwitchViewInputMock {
    func fullReset() {
        setNameLabelCallsCount = 0
        setNameLabelReceivedArguments = nil
        setNameLabelReceivedInvocations = []

        setSwitchButtonStateCallsCount = 0
        setSwitchButtonStateReceivedArguments = nil
        setSwitchButtonStateReceivedInvocations = []
    }
}
