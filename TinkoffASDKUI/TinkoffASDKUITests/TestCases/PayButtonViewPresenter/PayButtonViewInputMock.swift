//
//  PayButtonViewInputMock.swift
//  TinkoffASDKUI-Unit-Tests
//
//  Created by Aleksandr Pravosudov on 26.05.2023.
//

@testable import TinkoffASDKUI

final class PayButtonViewInputMock: IPayButtonViewInput {

    // MARK: - set

    var setConfigurationCallsCount = 0
    var setConfigurationReceivedArguments: Button.Configuration?
    var setConfigurationReceivedInvocations: [Button.Configuration] = []

    func set(configuration: Button.Configuration) {
        setConfigurationCallsCount += 1
        let arguments = configuration
        setConfigurationReceivedArguments = arguments
        setConfigurationReceivedInvocations.append(arguments)
    }

    // MARK: - set

    typealias SetArguments = (enabled: Bool, animated: Bool)

    var setEnabledCallsCount = 0
    var setEnabledReceivedArguments: SetArguments?
    var setEnabledReceivedInvocations: [SetArguments] = []

    func set(enabled: Bool, animated: Bool) {
        setEnabledCallsCount += 1
        let arguments = (enabled, animated)
        setEnabledReceivedArguments = arguments
        setEnabledReceivedInvocations.append(arguments)
    }

    // MARK: - startLoading

    var startLoadingCallsCount = 0

    func startLoading() {
        startLoadingCallsCount += 1
    }

    // MARK: - stopLoading

    var stopLoadingCallsCount = 0

    func stopLoading() {
        stopLoadingCallsCount += 1
    }
}

// MARK: - Public methods

extension PayButtonViewInputMock {
    func fullReset() {
        setConfigurationCallsCount = 0
        setConfigurationReceivedArguments = nil
        setConfigurationReceivedInvocations = []

        setEnabledCallsCount = 0
        setEnabledReceivedArguments = nil
        setEnabledReceivedInvocations = []

        startLoadingCallsCount = 0
        stopLoadingCallsCount = 0
    }
}
