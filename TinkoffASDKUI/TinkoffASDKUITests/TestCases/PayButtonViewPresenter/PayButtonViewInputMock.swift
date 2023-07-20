//
//  PayButtonViewInputMock.swift
//  TinkoffASDKUI-Unit-Tests
//
//  Created by Aleksandr Pravosudov on 26.05.2023.
//

@testable import TinkoffASDKUI

final class PayButtonViewInputMock: IPayButtonViewInput {

    // MARK: - setConfiguration

    typealias SetConfigurationArguments = Button.Configuration

    var setConfigurationCallsCount = 0
    var setConfigurationReceivedArguments: SetConfigurationArguments?
    var setConfigurationReceivedInvocations: [SetConfigurationArguments?] = []

    func set(configuration: Button.Configuration) {
        setConfigurationCallsCount += 1
        let arguments = configuration
        setConfigurationReceivedArguments = arguments
        setConfigurationReceivedInvocations.append(arguments)
    }

    // MARK: - setEnabledAnimated

    typealias SetEnabledAnimatedArguments = (enabled: Bool, animated: Bool)

    var setEnabledAnimatedCallsCount = 0
    var setEnabledAnimatedReceivedArguments: SetEnabledAnimatedArguments?
    var setEnabledAnimatedReceivedInvocations: [SetEnabledAnimatedArguments?] = []

    func set(enabled: Bool, animated: Bool) {
        setEnabledAnimatedCallsCount += 1
        let arguments = (enabled, animated)
        setEnabledAnimatedReceivedArguments = arguments
        setEnabledAnimatedReceivedInvocations.append(arguments)
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

// MARK: - Resets

extension PayButtonViewInputMock {
    func fullReset() {
        setConfigurationCallsCount = 0
        setConfigurationReceivedArguments = nil
        setConfigurationReceivedInvocations = []

        setEnabledAnimatedCallsCount = 0
        setEnabledAnimatedReceivedArguments = nil
        setEnabledAnimatedReceivedInvocations = []

        startLoadingCallsCount = 0

        stopLoadingCallsCount = 0
    }
}
