//
//  YandexPayButtonContainerDelegateMock.swift
//  TinkoffASDKYandexPay-Unit-Tests
//
//  Created by Ivan Glushko on 20.04.2023.
//

import TinkoffASDKUI
import UIKit

final class YandexPayButtonContainerDelegateMock: IYandexPayButtonContainerDelegate {

    // MARK: - yandexPayButtonContainerDidCompletePaymentWithResult

    typealias YandexPayButtonContainerDidCompletePaymentWithResultArguments = (container: IYandexPayButtonContainer, result: PaymentResult)

    var yandexPayButtonContainerDidCompletePaymentWithResultCallsCount = 0
    var yandexPayButtonContainerDidCompletePaymentWithResultReceivedArguments: YandexPayButtonContainerDidCompletePaymentWithResultArguments?
    var yandexPayButtonContainerDidCompletePaymentWithResultReceivedInvocations: [YandexPayButtonContainerDidCompletePaymentWithResultArguments?] = []

    func yandexPayButtonContainer(_ container: IYandexPayButtonContainer, didCompletePaymentWithResult result: PaymentResult) {
        yandexPayButtonContainerDidCompletePaymentWithResultCallsCount += 1
        let arguments = (container, result)
        yandexPayButtonContainerDidCompletePaymentWithResultReceivedArguments = arguments
        yandexPayButtonContainerDidCompletePaymentWithResultReceivedInvocations.append(arguments)
    }

    // MARK: - yandexPayButtonContainerDidRequestViewControllerForPresentation

    typealias YandexPayButtonContainerDidRequestViewControllerForPresentationArguments = IYandexPayButtonContainer

    var yandexPayButtonContainerDidRequestViewControllerForPresentationCallsCount = 0
    var yandexPayButtonContainerDidRequestViewControllerForPresentationReceivedArguments: YandexPayButtonContainerDidRequestViewControllerForPresentationArguments?
    var yandexPayButtonContainerDidRequestViewControllerForPresentationReceivedInvocations: [YandexPayButtonContainerDidRequestViewControllerForPresentationArguments?] = []
    var yandexPayButtonContainerDidRequestViewControllerForPresentationReturnValue: UIViewController?

    func yandexPayButtonContainerDidRequestViewControllerForPresentation(_ container: IYandexPayButtonContainer) -> UIViewController? {
        yandexPayButtonContainerDidRequestViewControllerForPresentationCallsCount += 1
        let arguments = container
        yandexPayButtonContainerDidRequestViewControllerForPresentationReceivedArguments = arguments
        yandexPayButtonContainerDidRequestViewControllerForPresentationReceivedInvocations.append(arguments)
        return yandexPayButtonContainerDidRequestViewControllerForPresentationReturnValue
    }

    // MARK: - yandexPayButtonContainer

    typealias YandexPayButtonContainerArguments = (container: IYandexPayButtonContainer, completion: (_ paymentFlow: PaymentFlow?) -> Void)

    var yandexPayButtonContainerCallsCount = 0
    var yandexPayButtonContainerReceivedArguments: YandexPayButtonContainerArguments?
    var yandexPayButtonContainerReceivedInvocations: [YandexPayButtonContainerArguments?] = []
    var yandexPayButtonContainerCompletionClosureInput: PaymentFlow??

    func yandexPayButtonContainer(_ container: IYandexPayButtonContainer, didRequestPaymentFlow completion: @escaping (_ paymentFlow: PaymentFlow?) -> Void) {
        yandexPayButtonContainerCallsCount += 1
        let arguments = (container, completion)
        yandexPayButtonContainerReceivedArguments = arguments
        yandexPayButtonContainerReceivedInvocations.append(arguments)
        if let yandexPayButtonContainerCompletionClosureInput = yandexPayButtonContainerCompletionClosureInput {
            completion(yandexPayButtonContainerCompletionClosureInput)
        }
    }
}

// MARK: - Resets

extension YandexPayButtonContainerDelegateMock {
    func fullReset() {
        yandexPayButtonContainerDidCompletePaymentWithResultCallsCount = 0
        yandexPayButtonContainerDidCompletePaymentWithResultReceivedArguments = nil
        yandexPayButtonContainerDidCompletePaymentWithResultReceivedInvocations = []

        yandexPayButtonContainerDidRequestViewControllerForPresentationCallsCount = 0
        yandexPayButtonContainerDidRequestViewControllerForPresentationReceivedArguments = nil
        yandexPayButtonContainerDidRequestViewControllerForPresentationReceivedInvocations = []

        yandexPayButtonContainerCallsCount = 0
        yandexPayButtonContainerReceivedArguments = nil
        yandexPayButtonContainerReceivedInvocations = []
        yandexPayButtonContainerCompletionClosureInput = nil
    }
}
