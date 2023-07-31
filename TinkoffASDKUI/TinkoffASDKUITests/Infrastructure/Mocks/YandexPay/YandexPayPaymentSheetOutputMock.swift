//
//  YandexPayPaymentSheetOutputMock.swift
//  Pods
//
//  Created by Ivan Glushko on 20.04.2023.
//

@testable import TinkoffASDKUI

final class YandexPayPaymentSheetOutputMock: IYandexPayPaymentSheetOutput {

    // MARK: - yandexPayPaymentSheet

    typealias YandexPayPaymentSheetArguments = PaymentResult

    var yandexPayPaymentSheetCallsCount = 0
    var yandexPayPaymentSheetReceivedArguments: YandexPayPaymentSheetArguments?
    var yandexPayPaymentSheetReceivedInvocations: [YandexPayPaymentSheetArguments?] = []

    func yandexPayPaymentSheet(completedWith result: PaymentResult) {
        yandexPayPaymentSheetCallsCount += 1
        let arguments = result
        yandexPayPaymentSheetReceivedArguments = arguments
        yandexPayPaymentSheetReceivedInvocations.append(arguments)
    }
}

// MARK: - Resets

extension YandexPayPaymentSheetOutputMock {
    func fullReset() {
        yandexPayPaymentSheetCallsCount = 0
        yandexPayPaymentSheetReceivedArguments = nil
        yandexPayPaymentSheetReceivedInvocations = []
    }
}
