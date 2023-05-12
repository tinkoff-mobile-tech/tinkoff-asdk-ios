//
//  YandexPayPaymentSheetOutputMock.swift
//  Pods
//
//  Created by Ivan Glushko on 20.04.2023.
//

@testable import TinkoffASDKUI

final class YandexPayPaymentSheetOutputMock: IYandexPayPaymentSheetOutput {

    // MARK: - yandexPayPaymentSheet

    var yandexPayPaymentSheetCallsCount = 0
    var yandexPayPaymentSheetReceivedArguments: PaymentResult?
    var yandexPayPaymentSheetReceivedInvocations: [PaymentResult] = []

    func yandexPayPaymentSheet(completedWith result: PaymentResult) {
        yandexPayPaymentSheetCallsCount += 1
        let arguments = result
        yandexPayPaymentSheetReceivedArguments = arguments
        yandexPayPaymentSheetReceivedInvocations.append(arguments)
    }
}
