//
//  SBPPaymentSheetPresenterOutputMock.swift
//  TinkoffASDKUI-Unit-Tests
//
//  Created by Aleksandr Pravosudov on 20.04.2023.
//

@testable import TinkoffASDKUI

final class SBPPaymentSheetPresenterOutputMock: ISBPPaymentSheetPresenterOutput {

    // MARK: - sbpPaymentSheet

    typealias SbpPaymentSheetArguments = PaymentResult

    var sbpPaymentSheetCallsCount = 0
    var sbpPaymentSheetReceivedArguments: SbpPaymentSheetArguments?
    var sbpPaymentSheetReceivedInvocations: [SbpPaymentSheetArguments?] = []

    func sbpPaymentSheet(completedWith result: PaymentResult) {
        sbpPaymentSheetCallsCount += 1
        let arguments = result
        sbpPaymentSheetReceivedArguments = arguments
        sbpPaymentSheetReceivedInvocations.append(arguments)
    }
}

// MARK: - Resets

extension SBPPaymentSheetPresenterOutputMock {
    func fullReset() {
        sbpPaymentSheetCallsCount = 0
        sbpPaymentSheetReceivedArguments = nil
        sbpPaymentSheetReceivedInvocations = []
    }
}
