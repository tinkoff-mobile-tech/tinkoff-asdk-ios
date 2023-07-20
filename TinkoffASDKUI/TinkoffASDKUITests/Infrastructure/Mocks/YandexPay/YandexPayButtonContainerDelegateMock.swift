//
//  YandexPayButtonContainerDelegateMock.swift
//  TinkoffASDKYandexPay-Unit-Tests
//
//  Created by Ivan Glushko on 20.04.2023.
//

import TinkoffASDKUI
import UIKit

final class YandexPayButtonContainerDelegateMock: IYandexPayButtonContainerDelegate {

    // MARK: - yandexPayButtonContainerContainerResult

    typealias YandexPayButtonContainerContainerResultArguments = (container: IYandexPayButtonContainer, result: PaymentResult)

    var yandexPayButtonContainerContainerResultCallsCount = 0
    var yandexPayButtonContainerContainerResultReceivedArguments: YandexPayButtonContainerContainerResultArguments?
    var yandexPayButtonContainerContainerResultReceivedInvocations: [YandexPayButtonContainerContainerResultArguments?] = []

    func yandexPayButtonContainer(_ container: IYandexPayButtonContainer, didCompletePaymentWithResult result: PaymentResult) {
        yandexPayButtonContainerContainerResultCallsCount += 1
        let arguments = (container, result)
        yandexPayButtonContainerContainerResultReceivedArguments = arguments
        yandexPayButtonContainerContainerResultReceivedInvocations.append(arguments)
    }

    // MARK: - yandexPayButtonContainerDidRequestViewControllerForPresentationContainer

    typealias YandexPayButtonContainerDidRequestViewControllerForPresentationContainerArguments = IYandexPayButtonContainer

    var yandexPayButtonContainerDidRequestViewControllerForPresentationContainerCallsCount = 0
    var yandexPayButtonContainerDidRequestViewControllerForPresentationContainerReceivedArguments: YandexPayButtonContainerDidRequestViewControllerForPresentationContainerArguments?
    var yandexPayButtonContainerDidRequestViewControllerForPresentationContainerReceivedInvocations: [YandexPayButtonContainerDidRequestViewControllerForPresentationContainerArguments?] = []
    var yandexPayButtonContainerDidRequestViewControllerForPresentationContainerReturnValue: UIViewController?

    func yandexPayButtonContainerDidRequestViewControllerForPresentation(_ container: IYandexPayButtonContainer) -> UIViewController? {
        yandexPayButtonContainerDidRequestViewControllerForPresentationContainerCallsCount += 1
        let arguments = container
        yandexPayButtonContainerDidRequestViewControllerForPresentationContainerReceivedArguments = arguments
        yandexPayButtonContainerDidRequestViewControllerForPresentationContainerReceivedInvocations.append(arguments)
        return yandexPayButtonContainerDidRequestViewControllerForPresentationContainerReturnValue
    }

    // MARK: - yandexPayButtonContainerContainer

    typealias YandexPayButtonContainerContainerArguments = (container: IYandexPayButtonContainer, completion: (_ paymentFlow: PaymentFlow?) -> Void)

    var yandexPayButtonContainerContainerCallsCount = 0
    var yandexPayButtonContainerContainerReceivedArguments: YandexPayButtonContainerContainerArguments?
    var yandexPayButtonContainerContainerReceivedInvocations: [YandexPayButtonContainerContainerArguments?] = []
    var yandexPayButtonContainerContainerCompletionClosureInput: PaymentFlow??

    func yandexPayButtonContainer(_ container: IYandexPayButtonContainer, didRequestPaymentFlow completion: @escaping (_ paymentFlow: PaymentFlow?) -> Void) {
        yandexPayButtonContainerContainerCallsCount += 1
        let arguments = (container, completion)
        yandexPayButtonContainerContainerReceivedArguments = arguments
        yandexPayButtonContainerContainerReceivedInvocations.append(arguments)
        if let yandexPayButtonContainerContainerCompletionClosureInput = yandexPayButtonContainerContainerCompletionClosureInput {
            completion(yandexPayButtonContainerContainerCompletionClosureInput)
        }
    }
}

// MARK: - Resets

extension YandexPayButtonContainerDelegateMock {
    func fullReset() {
        yandexPayButtonContainerContainerResultCallsCount = 0
        yandexPayButtonContainerContainerResultReceivedArguments = nil
        yandexPayButtonContainerContainerResultReceivedInvocations = []

        yandexPayButtonContainerDidRequestViewControllerForPresentationContainerCallsCount = 0
        yandexPayButtonContainerDidRequestViewControllerForPresentationContainerReceivedArguments = nil
        yandexPayButtonContainerDidRequestViewControllerForPresentationContainerReceivedInvocations = []

        yandexPayButtonContainerContainerCallsCount = 0
        yandexPayButtonContainerContainerReceivedArguments = nil
        yandexPayButtonContainerContainerReceivedInvocations = []
        yandexPayButtonContainerContainerCompletionClosureInput = nil
    }
}
