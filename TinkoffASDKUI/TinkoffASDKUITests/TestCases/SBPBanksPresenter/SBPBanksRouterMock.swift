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

    var closeScreenCallsCount = 0
    var closeScreenCompletionShouldExecute = false

    func closeScreen(completion: VoidBlock?) {
        closeScreenCallsCount += 1
        if closeScreenCompletionShouldExecute {
            completion?()
        }
    }

    // MARK: - show

    typealias ShowArguments = (banks: [SBPBank], qrPayload: GetQRPayload?, paymentSheetOutput: ISBPPaymentSheetPresenterOutput?)

    var showCallsCount = 0
    var showReceivedArguments: ShowArguments?
    var showReceivedInvocations: [ShowArguments] = []

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
    var showPaymentSheetReceivedInvocations: [ShowPaymentSheetArguments] = []

    func showPaymentSheet(paymentId: String, output: ISBPPaymentSheetPresenterOutput?) {
        showPaymentSheetCallsCount += 1
        let arguments = (paymentId, output)
        showPaymentSheetReceivedArguments = arguments
        showPaymentSheetReceivedInvocations.append(arguments)
    }
}
