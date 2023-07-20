//
//  SBPBanksRouterMock.swift
//  TinkoffASDKUI-Unit-Tests
//
//  Created by Aleksandr Pravosudov on 20.04.2023.
//

import TinkoffASDKCore
@testable import TinkoffASDKUI

final class SBPBanksRouterMock: ISBPBanksRouter {

    // MARK: - closeScreen

    typealias CloseScreenArguments = VoidBlock

    var closeScreenCallsCount = 0
    var closeScreenReceivedArguments: CloseScreenArguments?
    var closeScreenReceivedInvocations: [CloseScreenArguments?] = []
    var closeScreenCompletionShouldExecute = false

    func closeScreen(completion: VoidBlock?) {
        closeScreenCallsCount += 1
        let arguments = completion
        closeScreenReceivedArguments = arguments
        closeScreenReceivedInvocations.append(arguments)
        if closeScreenCompletionShouldExecute {
            completion?()
        }
    }

    // MARK: - show

    typealias ShowArguments = (banks: [SBPBank], qrPayload: GetQRPayload?, paymentSheetOutput: ISBPPaymentSheetPresenterOutput?)

    var showCallsCount = 0
    var showReceivedArguments: ShowArguments?
    var showReceivedInvocations: [ShowArguments?] = []

    func show(banks: [SBPBank], qrPayload: GetQRPayload?, paymentSheetOutput: ISBPPaymentSheetPresenterOutput?) {
        showCallsCount += 1
        let arguments = (banks, qrPayload, paymentSheetOutput)
        showReceivedArguments = arguments
        showReceivedInvocations.append(arguments)
    }

    // MARK: - showDidNotFindBankAppAlert

    var showDidNotFindBankAppAlertCallsCount = 0

    func showDidNotFindBankAppAlert() {
        showDidNotFindBankAppAlertCallsCount += 1
    }

    // MARK: - showPaymentSheet

    typealias ShowPaymentSheetArguments = (paymentId: String, output: ISBPPaymentSheetPresenterOutput?)

    var showPaymentSheetCallsCount = 0
    var showPaymentSheetReceivedArguments: ShowPaymentSheetArguments?
    var showPaymentSheetReceivedInvocations: [ShowPaymentSheetArguments?] = []

    func showPaymentSheet(paymentId: String, output: ISBPPaymentSheetPresenterOutput?) {
        showPaymentSheetCallsCount += 1
        let arguments = (paymentId, output)
        showPaymentSheetReceivedArguments = arguments
        showPaymentSheetReceivedInvocations.append(arguments)
    }
}

// MARK: - Resets

extension SBPBanksRouterMock {
    func fullReset() {
        closeScreenCallsCount = 0
        closeScreenReceivedArguments = nil
        closeScreenReceivedInvocations = []
        closeScreenCompletionShouldExecute = false

        showCallsCount = 0
        showReceivedArguments = nil
        showReceivedInvocations = []

        showDidNotFindBankAppAlertCallsCount = 0

        showPaymentSheetCallsCount = 0
        showPaymentSheetReceivedArguments = nil
        showPaymentSheetReceivedInvocations = []
    }
}
