//
//  YandexPayPaymentFlowDelegateMock.swift
//  TinkoffASDKUI-Unit-Tests
//
//  Created by Ivan Glushko on 20.04.2023.
//

@testable import TinkoffASDKUI

final class YandexPayPaymentFlowDelegateMock: YandexPayPaymentFlowDelegate {

    // MARK: - yandexPayPaymentFlowDidRequestViewControllerForPresentation

    var yandexPayPaymentFlowDidRequestViewControllerForPresentationCallsCount = 0
    var yandexPayPaymentFlowDidRequestViewControllerForPresentationReceivedArguments: IYandexPayPaymentFlow?
    var yandexPayPaymentFlowDidRequestViewControllerForPresentationReceivedInvocations: [IYandexPayPaymentFlow] = []
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

    var didCompleteWithCallsCount = 0
    var didCompleteWithReceivedArguments: YandexPayPaymentFlowArguments?
    var didCompleteWithReceivedInvocations: [YandexPayPaymentFlowArguments] = []

    func yandexPayPaymentFlow(_ flow: IYandexPayPaymentFlow, didCompleteWith result: PaymentResult) {
        didCompleteWithCallsCount += 1
        let arguments = (flow, result)
        didCompleteWithReceivedArguments = arguments
        didCompleteWithReceivedInvocations.append(arguments)
    }
}
