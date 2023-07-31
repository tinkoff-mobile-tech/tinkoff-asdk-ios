//
//  YandexPayPaymentSheetAssemblyMock.swift
//  TinkoffASDKUI-Unit-Tests
//
//  Created by Ivan Glushko on 20.04.2023.
//

@testable import TinkoffASDKUI
import UIKit

final class YandexPayPaymentSheetAssemblyMock: IYandexPayPaymentSheetAssembly {

    // MARK: - yandexPayPaymentSheet

    typealias YandexPayPaymentSheetArguments = (paymentFlow: PaymentFlow, base64Token: String, output: IYandexPayPaymentSheetOutput)

    var yandexPayPaymentSheetCallsCount = 0
    var yandexPayPaymentSheetReceivedArguments: YandexPayPaymentSheetArguments?
    var yandexPayPaymentSheetReceivedInvocations: [YandexPayPaymentSheetArguments?] = []
    var yandexPayPaymentSheetReturnValue: UIViewController!

    func yandexPayPaymentSheet(paymentFlow: PaymentFlow, base64Token: String, output: IYandexPayPaymentSheetOutput) -> UIViewController {
        yandexPayPaymentSheetCallsCount += 1
        let arguments = (paymentFlow, base64Token, output)
        yandexPayPaymentSheetReceivedArguments = arguments
        yandexPayPaymentSheetReceivedInvocations.append(arguments)
        return yandexPayPaymentSheetReturnValue
    }
}

// MARK: - Resets

extension YandexPayPaymentSheetAssemblyMock {
    func fullReset() {
        yandexPayPaymentSheetCallsCount = 0
        yandexPayPaymentSheetReceivedArguments = nil
        yandexPayPaymentSheetReceivedInvocations = []
    }
}
