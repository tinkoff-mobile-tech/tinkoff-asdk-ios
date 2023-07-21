//
//  SwitchViewOutputMock.swift
//  TinkoffASDKUI-Unit-Tests
//
//  Created by Aleksandr Pravosudov on 23.05.2023.
//

@testable import TinkoffASDKUI

final class SwitchViewOutputMock: ISwitchViewOutput {
    var view: ISwitchViewInput?

    var isOn: Bool {
        get { return underlyingIsOn }
        set(value) { underlyingIsOn = value }
    }

    var underlyingIsOn = false

    // MARK: - switchButtonValueChanged

    typealias SwitchButtonValueChangedArguments = Bool

    var switchButtonValueChangedCallsCount = 0
    var switchButtonValueChangedReceivedArguments: SwitchButtonValueChangedArguments?
    var switchButtonValueChangedReceivedInvocations: [SwitchButtonValueChangedArguments?] = []

    func switchButtonValueChanged(to isOn: Bool) {
        switchButtonValueChangedCallsCount += 1
        let arguments = isOn
        switchButtonValueChangedReceivedArguments = arguments
        switchButtonValueChangedReceivedInvocations.append(arguments)
    }
}

// MARK: - Resets

extension SwitchViewOutputMock {
    func fullReset() {
        switchButtonValueChangedCallsCount = 0
        switchButtonValueChangedReceivedArguments = nil
        switchButtonValueChangedReceivedInvocations = []
    }
}
