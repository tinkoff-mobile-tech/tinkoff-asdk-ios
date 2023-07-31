//
//  YandexPayPaymentFlowMock.swift
//  Pods-ASDKSample
//
//  Created by Ivan Glushko on 20.04.2023.
//

import TinkoffASDKUI

final class YandexPayPaymentFlowMock: IYandexPayPaymentFlow {

    // MARK: - start

    typealias StartArguments = (paymentFlow: PaymentFlow, base64Token: String)

    var startCallsCount = 0
    var startReceivedArguments: StartArguments?
    var startReceivedInvocations: [StartArguments?] = []

    func start(with paymentFlow: PaymentFlow, base64Token: String) {
        startCallsCount += 1
        let arguments = (paymentFlow, base64Token)
        startReceivedArguments = arguments
        startReceivedInvocations.append(arguments)
    }
}

// MARK: - Resets

extension YandexPayPaymentFlowMock {
    func fullReset() {
        startCallsCount = 0
        startReceivedArguments = nil
        startReceivedInvocations = []
    }
}
