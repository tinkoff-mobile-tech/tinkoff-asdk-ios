//
//  TinkoffPayControllerDelegateMock.swift
//  TinkoffASDKUI-Unit-Tests
//
//  Created by Никита Васильев on 01.06.2023.
//

import TinkoffASDKCore
@testable import TinkoffASDKUI

final class TinkoffPayControllerDelegateMock: TinkoffPayControllerDelegate {

    // MARK: - tinkoffPayController

    typealias TinkoffPayControllerDidReceiveIntermediateArguments = (tinkoffPayController: ITinkoffPayController, paymentState: GetPaymentStatePayload)

    var tinkoffPayControllerCallsCount = 0
    var tinkoffPayControllerReceivedArguments: TinkoffPayControllerDidReceiveIntermediateArguments?
    var tinkoffPayControllerReceivedInvocations: [TinkoffPayControllerDidReceiveIntermediateArguments] = []

    func tinkoffPayController(_ tinkoffPayController: ITinkoffPayController, didReceiveIntermediate paymentState: GetPaymentStatePayload) {
        tinkoffPayControllerCallsCount += 1
        let arguments = (tinkoffPayController, paymentState)
        tinkoffPayControllerReceivedArguments = arguments
        tinkoffPayControllerReceivedInvocations.append(arguments)
    }

    // MARK: - tinkoffPayController

    typealias TinkoffPayControllerDidOpenTinkoffPayArguments = (tinkoffPayController: ITinkoffPayController, url: URL)

    var tinkoffPayControllerDidOpenURLCallsCount = 0
    var tinkoffPayControllerDidOpenURLReceivedArguments: TinkoffPayControllerDidOpenTinkoffPayArguments?
    var tinkoffPayControllerDidOpenURLReceivedInvocations: [TinkoffPayControllerDidOpenTinkoffPayArguments] = []

    func tinkoffPayController(_ tinkoffPayController: ITinkoffPayController, didOpenTinkoffPay url: URL) {
        tinkoffPayControllerDidOpenURLCallsCount += 1
        let arguments = (tinkoffPayController, url)
        tinkoffPayControllerDidOpenURLReceivedArguments = arguments
        tinkoffPayControllerDidOpenURLReceivedInvocations.append(arguments)
    }

    // MARK: - tinkoffPayController

    typealias TinkoffPayControllerInabilityToOpenTinkoffPayArguments = (tinkoffPayController: ITinkoffPayController, url: URL, error: Error)

    var tinkoffPayControllerInabilityToOpenTinkoffPayCallsCount = 0
    var tinkoffPayControllerInabilityToOpenTinkoffPayReceivedArguments: TinkoffPayControllerInabilityToOpenTinkoffPayArguments?
    var tinkoffPayControllerInabilityToOpenTinkoffPayReceivedInvocations: [TinkoffPayControllerInabilityToOpenTinkoffPayArguments] = []

    func tinkoffPayController(_ tinkoffPayController: ITinkoffPayController, completedDueToInabilityToOpenTinkoffPay url: URL, error: Error) {
        tinkoffPayControllerInabilityToOpenTinkoffPayCallsCount += 1
        let arguments = (tinkoffPayController, url, error)
        tinkoffPayControllerInabilityToOpenTinkoffPayReceivedArguments = arguments
        tinkoffPayControllerInabilityToOpenTinkoffPayReceivedInvocations.append(arguments)
    }

    // MARK: - tinkoffPayController

    typealias TinkoffPayControllerCompletedWithSuccessfulArguments = (tinkoffPayController: ITinkoffPayController, paymentState: GetPaymentStatePayload)

    var tinkoffPayControllerCompletedWithSuccessfulCallsCount = 0
    var tinkoffPayControllerCompletedWithSuccessfulReceivedArguments: TinkoffPayControllerCompletedWithSuccessfulArguments?
    var tinkoffPayControllerCompletedWithSuccessfulReceivedInvocations: [TinkoffPayControllerCompletedWithSuccessfulArguments] = []

    func tinkoffPayController(_ tinkoffPayController: ITinkoffPayController, completedWithSuccessful paymentState: GetPaymentStatePayload) {
        tinkoffPayControllerCompletedWithSuccessfulCallsCount += 1
        let arguments = (tinkoffPayController, paymentState)
        tinkoffPayControllerCompletedWithSuccessfulReceivedArguments = arguments
        tinkoffPayControllerCompletedWithSuccessfulReceivedInvocations.append(arguments)
    }

    // MARK: - tinkoffPayController

    typealias TinkoffPayControllerCompletedWithFailedArguments = (tinkoffPayController: ITinkoffPayController, paymentState: GetPaymentStatePayload, error: Error)

    var tinkoffPayControllerCompletedWithFailedCallsCount = 0
    var tinkoffPayControllerCompletedWithFailedReceivedArguments: TinkoffPayControllerCompletedWithFailedArguments?
    var tinkoffPayControllerCompletedWithFailedReceivedInvocations: [TinkoffPayControllerCompletedWithFailedArguments] = []

    func tinkoffPayController(_ tinkoffPayController: ITinkoffPayController, completedWithFailed paymentState: GetPaymentStatePayload, error: Error) {
        tinkoffPayControllerCompletedWithFailedCallsCount += 1
        let arguments = (tinkoffPayController, paymentState, error)
        tinkoffPayControllerCompletedWithFailedReceivedArguments = arguments
        tinkoffPayControllerCompletedWithFailedReceivedInvocations.append(arguments)
    }

    // MARK: - tinkoffPayController

    typealias TinkoffPayControllerCompletedWithTimeoutArguments = (tinkoffPayController: ITinkoffPayController, paymentState: GetPaymentStatePayload, error: Error)

    var tinkoffPayControllerCompletedWithTimeoutCallsCount = 0
    var tinkoffPayControllerCompletedWithTimeoutReceivedArguments: TinkoffPayControllerCompletedWithTimeoutArguments?
    var tinkoffPayControllerCompletedWithTimeoutReceivedInvocations: [TinkoffPayControllerCompletedWithTimeoutArguments] = []

    func tinkoffPayController(_ tinkoffPayController: ITinkoffPayController, completedWithTimeout paymentState: GetPaymentStatePayload, error: Error) {
        tinkoffPayControllerCompletedWithTimeoutCallsCount += 1
        let arguments = (tinkoffPayController, paymentState, error)
        tinkoffPayControllerCompletedWithTimeoutReceivedArguments = arguments
        tinkoffPayControllerCompletedWithTimeoutReceivedInvocations.append(arguments)
    }

    // MARK: - tinkoffPayController

    typealias TinkoffPayControllerCompletedWithErrorArguments = (tinkoffPayController: ITinkoffPayController, error: Error)

    var tinkoffPayControllerCompletedWithErrorCallsCount = 0
    var tinkoffPayControllerCompletedWithErrorReceivedArguments: TinkoffPayControllerCompletedWithErrorArguments?
    var tinkoffPayControllerCompletedWithErrorReceivedInvocations: [TinkoffPayControllerCompletedWithErrorArguments] = []

    func tinkoffPayController(_ tinkoffPayController: ITinkoffPayController, completedWith error: Error) {
        tinkoffPayControllerCompletedWithErrorCallsCount += 1
        let arguments = (tinkoffPayController, error)
        tinkoffPayControllerCompletedWithErrorReceivedArguments = arguments
        tinkoffPayControllerCompletedWithErrorReceivedInvocations.append(arguments)
    }
}
