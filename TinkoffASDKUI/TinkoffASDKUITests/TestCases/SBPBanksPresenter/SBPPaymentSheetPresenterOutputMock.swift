//
//  SBPPaymentSheetPresenterOutputMock.swift
//  TinkoffASDKUI-Unit-Tests
//
//  Created by Aleksandr Pravosudov on 20.04.2023.
//

@testable import TinkoffASDKUI

final class SBPPaymentSheetPresenterOutputMock: ISBPPaymentSheetPresenterOutput {

    // MARK: - sbpPaymentSheet

    var sbpPaymentSheetCallsCount = 0
    var sbpPaymentSheetReceivedArguments: PaymentResult?
    var sbpPaymentSheetReceivedInvocations: [PaymentResult] = []

    func sbpPaymentSheet(completedWith result: PaymentResult) {
        sbpPaymentSheetCallsCount += 1
        let arguments = result
        sbpPaymentSheetReceivedArguments = arguments
        sbpPaymentSheetReceivedInvocations.append(arguments)
    }
}
