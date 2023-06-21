//
//  PayButtonViewOutputMock.swift
//  TinkoffASDKUI-Unit-Tests
//
//  Created by Aleksandr Pravosudov on 23.05.2023.
//

@testable import TinkoffASDKUI

final class PayButtonViewOutputMock: IPayButtonViewOutput {
    var view: IPayButtonViewInput?
    var presentationState: PayButtonViewPresentationState {
        get { return underlyingPresentationState }
        set(value) { underlyingPresentationState = value }
    }

    var underlyingPresentationState: PayButtonViewPresentationState!
    var isLoading: Bool {
        get { return underlyingIsLoading }
        set(value) { underlyingIsLoading = value }
    }

    var underlyingIsLoading: Bool!
    var isEnabled: Bool {
        get { return underlyingIsEnabled }
        set(value) { underlyingIsEnabled = value }
    }

    var underlyingIsEnabled: Bool!

    // MARK: - payButtonTapped

    var payButtonTappedCallsCount = 0

    func payButtonTapped() {
        payButtonTappedCallsCount += 1
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

    // MARK: - set

    var setCallsCount = 0
    var setReceivedArguments: Bool?
    var setReceivedInvocations: [Bool] = []

    func set(enabled: Bool) {
        setCallsCount += 1
        let arguments = enabled
        setReceivedArguments = arguments
        setReceivedInvocations.append(arguments)
    }
}

// MARK: - Public methods

extension PayButtonViewOutputMock {
    func fullReset() {
        view = nil
        underlyingPresentationState = nil
        underlyingIsLoading = nil
        underlyingIsEnabled = nil

        payButtonTappedCallsCount = 0
        startLoadingCallsCount = 0
        stopLoadingCallsCount = 0

        setCallsCount = 0
        setReceivedArguments = nil
        setReceivedInvocations = []
    }
}
