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

    var yandexPayPaymentFlowCallsCount = 0
    var yandexPayPaymentFlowReceivedArguments: YandexPayPaymentFlowDelegate?
    var yandexPayPaymentFlowReceivedInvocations: [YandexPayPaymentFlowDelegate] = []
    var yandexPayPaymentFlowReturnValue: IYandexPayPaymentFlow!

    func yandexPayPaymentFlow(delegate: YandexPayPaymentFlowDelegate) -> IYandexPayPaymentFlow {
        yandexPayPaymentFlowCallsCount += 1
        let arguments = delegate
        yandexPayPaymentFlowReceivedArguments = arguments
        yandexPayPaymentFlowReceivedInvocations.append(arguments)
        return yandexPayPaymentFlowReturnValue
    }
}
