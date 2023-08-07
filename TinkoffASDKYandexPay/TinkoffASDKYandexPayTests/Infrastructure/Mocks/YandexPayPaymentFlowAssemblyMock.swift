//
//  YandexPayPaymentFlowAssemblyMock.swift
//  TinkoffASDKYandexPay-Unit-Tests
//
//  Created by Ivan Glushko on 19.04.2023.
//

import TinkoffASDKCore
@testable import TinkoffASDKUI
import TinkoffASDKYandexPay

final class YandexPayPaymentFlowAssemblyMock: IYandexPayPaymentFlowAssembly {

    // MARK: - yandexPayPaymentFlow

    typealias YandexPayPaymentFlowArguments = YandexPayPaymentFlowDelegate

    var yandexPayPaymentFlowCallsCount = 0
    var yandexPayPaymentFlowReceivedArguments: YandexPayPaymentFlowArguments?
    var yandexPayPaymentFlowReceivedInvocations: [YandexPayPaymentFlowArguments?] = []
    var yandexPayPaymentFlowReturnValue: IYandexPayPaymentFlow!

    func yandexPayPaymentFlow(delegate: YandexPayPaymentFlowDelegate) -> IYandexPayPaymentFlow {
        yandexPayPaymentFlowCallsCount += 1
        let arguments = delegate
        yandexPayPaymentFlowReceivedArguments = arguments
        yandexPayPaymentFlowReceivedInvocations.append(arguments)
        return yandexPayPaymentFlowReturnValue
    }
}

// MARK: - Resets

extension YandexPayPaymentFlowAssemblyMock {
    func fullReset() {
        yandexPayPaymentFlowCallsCount = 0
        yandexPayPaymentFlowReceivedArguments = nil
        yandexPayPaymentFlowReceivedInvocations = []
    }
}
