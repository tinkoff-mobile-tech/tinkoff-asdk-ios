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

    var underlyingIsOn: Bool = false

    // MARK: - switchButtonValueChanged

    var switchButtonValueChangedCallsCount = 0
    var switchButtonValueChangedReceivedArguments: Bool?
    var switchButtonValueChangedReceivedInvocations: [Bool] = []

    func switchButtonValueChanged(to isOn: Bool) {
        switchButtonValueChangedCallsCount += 1
        let arguments = isOn
        switchButtonValueChangedReceivedArguments = arguments
        switchButtonValueChangedReceivedInvocations.append(arguments)
    }
}
