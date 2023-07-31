//
//  YandexPayPaymentFlowDelegateMock.swift
//  TinkoffASDKUI-Unit-Tests
//
//  Created by Ivan Glushko on 20.04.2023.
//

@testable import TinkoffASDKUI
import UIKit

final class YandexPayPaymentFlowDelegateMock: YandexPayPaymentFlowDelegate {

    // MARK: - yandexPayPaymentFlowDidRequestViewControllerForPresentation

    typealias YandexPayPaymentFlowDidRequestViewControllerForPresentationArguments = IYandexPayPaymentFlow

    var yandexPayPaymentFlowDidRequestViewControllerForPresentationCallsCount = 0
    var yandexPayPaymentFlowDidRequestViewControllerForPresentationReceivedArguments: YandexPayPaymentFlowDidRequestViewControllerForPresentationArguments?
    var yandexPayPaymentFlowDidRequestViewControllerForPresentationReceivedInvocations: [YandexPayPaymentFlowDidRequestViewControllerForPresentationArguments?] = []
    var yandexPayPaymentFlowDidRequestViewControllerForPresentationReturnValue: UIViewController?

    func yandexPayPaymentFlowDidRequestViewControllerForPresentation(_ flow: IYandexPayPaymentFlow) -> UIViewController? {
        yandexPayPaymentFlowDidRequestViewControllerForPresentationCallsCount += 1
        let arguments = flow
        yandexPayPaymentFlowDidRequestViewControllerForPresentationReceivedArguments = arguments
        yandexPayPaymentFlowDidRequestViewControllerForPresentationReceivedInvocations.append(arguments)
        return yandexPayPaymentFlowDidRequestViewControllerForPresentationReturnValue
    }

    // MARK: - yandexPayPaymentFlow

    typealias YandexPayPaymentFlowArguments = (flow: IYandexPayPaymentFlow, result: PaymentResult)

    var yandexPayPaymentFlowCallsCount = 0
    var yandexPayPaymentFlowReceivedArguments: YandexPayPaymentFlowArguments?
    var yandexPayPaymentFlowReceivedInvocations: [YandexPayPaymentFlowArguments?] = []

    func yandexPayPaymentFlow(_ flow: IYandexPayPaymentFlow, didCompleteWith result: PaymentResult) {
        yandexPayPaymentFlowCallsCount += 1
        let arguments = (flow, result)
        yandexPayPaymentFlowReceivedArguments = arguments
        yandexPayPaymentFlowReceivedInvocations.append(arguments)
    }
}

// MARK: - Resets

extension YandexPayPaymentFlowDelegateMock {
    func fullReset() {
        yandexPayPaymentFlowDidRequestViewControllerForPresentationCallsCount = 0
        yandexPayPaymentFlowDidRequestViewControllerForPresentationReceivedArguments = nil
        yandexPayPaymentFlowDidRequestViewControllerForPresentationReceivedInvocations = []

        yandexPayPaymentFlowCallsCount = 0
        yandexPayPaymentFlowReceivedArguments = nil
        yandexPayPaymentFlowReceivedInvocations = []
    }
}
