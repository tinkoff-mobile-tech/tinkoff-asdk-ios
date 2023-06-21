//
//  SwitchViewInputMock.swift
//  TinkoffASDKUI-Unit-Tests
//
//  Created by Aleksandr Pravosudov on 30.05.2023.
//

@testable import TinkoffASDKUI

final class SwitchViewInputMock: ISwitchViewInput {

    // MARK: - setNameLabel

    var setNameLabelCallsCount = 0
    var setNameLabelReceivedArguments: String?
    var setNameLabelReceivedInvocations: [String?] = []

    func setNameLabel(text: String?) {
        setNameLabelCallsCount += 1
        let arguments = text
        setNameLabelReceivedArguments = arguments
        setNameLabelReceivedInvocations.append(arguments)
    }

    // MARK: - setSwitchButtonState

    var setSwitchButtonStateCallsCount = 0
    var setSwitchButtonStateReceivedArguments: Bool?
    var setSwitchButtonStateReceivedInvocations: [Bool] = []

    func setSwitchButtonState(isOn: Bool) {
        setSwitchButtonStateCallsCount += 1
        let arguments = isOn
        setSwitchButtonStateReceivedArguments = arguments
        setSwitchButtonStateReceivedInvocations.append(arguments)
    }
}

// MARK: - Public methods

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
