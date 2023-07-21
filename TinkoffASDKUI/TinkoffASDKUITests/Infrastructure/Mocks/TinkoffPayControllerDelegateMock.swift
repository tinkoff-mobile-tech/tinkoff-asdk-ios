//
//  TinkoffPayControllerDelegateMock.swift
//  TinkoffASDKUI-Unit-Tests
//
//  Created by Никита Васильев on 01.06.2023.
//

import Foundation
import TinkoffASDKCore
@testable import TinkoffASDKUI

final class TinkoffPayControllerDelegateMock: TinkoffPayControllerDelegate {

    // MARK: - tinkoffPayControllerDidReceiveIntermediate

    typealias TinkoffPayControllerDidReceiveIntermediateArguments = (tinkoffPayController: ITinkoffPayController, paymentState: GetPaymentStatePayload)

    var tinkoffPayControllerDidReceiveIntermediateCallsCount = 0
    var tinkoffPayControllerDidReceiveIntermediateReceivedArguments: TinkoffPayControllerDidReceiveIntermediateArguments?
    var tinkoffPayControllerDidReceiveIntermediateReceivedInvocations: [TinkoffPayControllerDidReceiveIntermediateArguments?] = []

    func tinkoffPayController(_ tinkoffPayController: ITinkoffPayController, didReceiveIntermediate paymentState: GetPaymentStatePayload) {
        tinkoffPayControllerDidReceiveIntermediateCallsCount += 1
        let arguments = (tinkoffPayController, paymentState)
        tinkoffPayControllerDidReceiveIntermediateReceivedArguments = arguments
        tinkoffPayControllerDidReceiveIntermediateReceivedInvocations.append(arguments)
    }

    // MARK: - tinkoffPayControllerDidOpenTinkoffPay

    typealias TinkoffPayControllerDidOpenTinkoffPayArguments = (tinkoffPayController: ITinkoffPayController, url: URL)

    var tinkoffPayControllerDidOpenTinkoffPayCallsCount = 0
    var tinkoffPayControllerDidOpenTinkoffPayReceivedArguments: TinkoffPayControllerDidOpenTinkoffPayArguments?
    var tinkoffPayControllerDidOpenTinkoffPayReceivedInvocations: [TinkoffPayControllerDidOpenTinkoffPayArguments?] = []

    func tinkoffPayController(_ tinkoffPayController: ITinkoffPayController, didOpenTinkoffPay url: URL) {
        tinkoffPayControllerDidOpenTinkoffPayCallsCount += 1
        let arguments = (tinkoffPayController, url)
        tinkoffPayControllerDidOpenTinkoffPayReceivedArguments = arguments
        tinkoffPayControllerDidOpenTinkoffPayReceivedInvocations.append(arguments)
    }

    // MARK: - tinkoffPayControllerCompletedDueToInabilityToOpenTinkoffPay

    typealias TinkoffPayControllerCompletedDueToInabilityToOpenTinkoffPayArguments = (tinkoffPayController: ITinkoffPayController, url: URL, error: Error)

    var tinkoffPayControllerCompletedDueToInabilityToOpenTinkoffPayCallsCount = 0
    var tinkoffPayControllerCompletedDueToInabilityToOpenTinkoffPayReceivedArguments: TinkoffPayControllerCompletedDueToInabilityToOpenTinkoffPayArguments?
    var tinkoffPayControllerCompletedDueToInabilityToOpenTinkoffPayReceivedInvocations: [TinkoffPayControllerCompletedDueToInabilityToOpenTinkoffPayArguments?] = []

    func tinkoffPayController(_ tinkoffPayController: ITinkoffPayController, completedDueToInabilityToOpenTinkoffPay url: URL, error: Error) {
        tinkoffPayControllerCompletedDueToInabilityToOpenTinkoffPayCallsCount += 1
        let arguments = (tinkoffPayController, url, error)
        tinkoffPayControllerCompletedDueToInabilityToOpenTinkoffPayReceivedArguments = arguments
        tinkoffPayControllerCompletedDueToInabilityToOpenTinkoffPayReceivedInvocations.append(arguments)
    }

    // MARK: - tinkoffPayControllerCompletedWithSuccessful

    typealias TinkoffPayControllerCompletedWithSuccessfulArguments = (tinkoffPayController: ITinkoffPayController, paymentState: GetPaymentStatePayload)

    var tinkoffPayControllerCompletedWithSuccessfulCallsCount = 0
    var tinkoffPayControllerCompletedWithSuccessfulReceivedArguments: TinkoffPayControllerCompletedWithSuccessfulArguments?
    var tinkoffPayControllerCompletedWithSuccessfulReceivedInvocations: [TinkoffPayControllerCompletedWithSuccessfulArguments?] = []

    func tinkoffPayController(_ tinkoffPayController: ITinkoffPayController, completedWithSuccessful paymentState: GetPaymentStatePayload) {
        tinkoffPayControllerCompletedWithSuccessfulCallsCount += 1
        let arguments = (tinkoffPayController, paymentState)
        tinkoffPayControllerCompletedWithSuccessfulReceivedArguments = arguments
        tinkoffPayControllerCompletedWithSuccessfulReceivedInvocations.append(arguments)
    }

    // MARK: - tinkoffPayControllerCompletedWithFailed

    typealias TinkoffPayControllerCompletedWithFailedArguments = (tinkoffPayController: ITinkoffPayController, paymentState: GetPaymentStatePayload, error: Error)

    var tinkoffPayControllerCompletedWithFailedCallsCount = 0
    var tinkoffPayControllerCompletedWithFailedReceivedArguments: TinkoffPayControllerCompletedWithFailedArguments?
    var tinkoffPayControllerCompletedWithFailedReceivedInvocations: [TinkoffPayControllerCompletedWithFailedArguments?] = []

    func tinkoffPayController(_ tinkoffPayController: ITinkoffPayController, completedWithFailed paymentState: GetPaymentStatePayload, error: Error) {
        tinkoffPayControllerCompletedWithFailedCallsCount += 1
        let arguments = (tinkoffPayController, paymentState, error)
        tinkoffPayControllerCompletedWithFailedReceivedArguments = arguments
        tinkoffPayControllerCompletedWithFailedReceivedInvocations.append(arguments)
    }

    // MARK: - tinkoffPayControllerCompletedWithTimeout

    typealias TinkoffPayControllerCompletedWithTimeoutArguments = (tinkoffPayController: ITinkoffPayController, paymentState: GetPaymentStatePayload, error: Error)

    var tinkoffPayControllerCompletedWithTimeoutCallsCount = 0
    var tinkoffPayControllerCompletedWithTimeoutReceivedArguments: TinkoffPayControllerCompletedWithTimeoutArguments?
    var tinkoffPayControllerCompletedWithTimeoutReceivedInvocations: [TinkoffPayControllerCompletedWithTimeoutArguments?] = []

    func tinkoffPayController(_ tinkoffPayController: ITinkoffPayController, completedWithTimeout paymentState: GetPaymentStatePayload, error: Error) {
        tinkoffPayControllerCompletedWithTimeoutCallsCount += 1
        let arguments = (tinkoffPayController, paymentState, error)
        tinkoffPayControllerCompletedWithTimeoutReceivedArguments = arguments
        tinkoffPayControllerCompletedWithTimeoutReceivedInvocations.append(arguments)
    }

    // MARK: - tinkoffPayControllerCompletedWith

    typealias TinkoffPayControllerCompletedWithArguments = (tinkoffPayController: ITinkoffPayController, error: Error)

    var tinkoffPayControllerCompletedWithCallsCount = 0
    var tinkoffPayControllerCompletedWithReceivedArguments: TinkoffPayControllerCompletedWithArguments?
    var tinkoffPayControllerCompletedWithReceivedInvocations: [TinkoffPayControllerCompletedWithArguments?] = []

    func tinkoffPayController(_ tinkoffPayController: ITinkoffPayController, completedWith error: Error) {
        tinkoffPayControllerCompletedWithCallsCount += 1
        let arguments = (tinkoffPayController, error)
        tinkoffPayControllerCompletedWithReceivedArguments = arguments
        tinkoffPayControllerCompletedWithReceivedInvocations.append(arguments)
    }
}

// MARK: - Resets

extension TinkoffPayControllerDelegateMock {
    func fullReset() {
        tinkoffPayControllerDidReceiveIntermediateCallsCount = 0
        tinkoffPayControllerDidReceiveIntermediateReceivedArguments = nil
        tinkoffPayControllerDidReceiveIntermediateReceivedInvocations = []

        tinkoffPayControllerDidOpenTinkoffPayCallsCount = 0
        tinkoffPayControllerDidOpenTinkoffPayReceivedArguments = nil
        tinkoffPayControllerDidOpenTinkoffPayReceivedInvocations = []

        tinkoffPayControllerCompletedDueToInabilityToOpenTinkoffPayCallsCount = 0
        tinkoffPayControllerCompletedDueToInabilityToOpenTinkoffPayReceivedArguments = nil
        tinkoffPayControllerCompletedDueToInabilityToOpenTinkoffPayReceivedInvocations = []

        tinkoffPayControllerCompletedWithSuccessfulCallsCount = 0
        tinkoffPayControllerCompletedWithSuccessfulReceivedArguments = nil
        tinkoffPayControllerCompletedWithSuccessfulReceivedInvocations = []

        tinkoffPayControllerCompletedWithFailedCallsCount = 0
        tinkoffPayControllerCompletedWithFailedReceivedArguments = nil
        tinkoffPayControllerCompletedWithFailedReceivedInvocations = []

        tinkoffPayControllerCompletedWithTimeoutCallsCount = 0
        tinkoffPayControllerCompletedWithTimeoutReceivedArguments = nil
        tinkoffPayControllerCompletedWithTimeoutReceivedInvocations = []

        tinkoffPayControllerCompletedWithCallsCount = 0
        tinkoffPayControllerCompletedWithReceivedArguments = nil
        tinkoffPayControllerCompletedWithReceivedInvocations = []
    }
}
