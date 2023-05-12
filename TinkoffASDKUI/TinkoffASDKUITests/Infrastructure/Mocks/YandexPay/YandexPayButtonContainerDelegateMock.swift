//
//  YandexPayButtonContainerDelegateMock.swift
//  TinkoffASDKYandexPay-Unit-Tests
//
//  Created by Ivan Glushko on 20.04.2023.
//

import TinkoffASDKUI

final class YandexPayButtonContainerDelegateMock: IYandexPayButtonContainerDelegate {

    // MARK: - yandexPayButtonContainer - didCompletePaymentWithResult

    typealias DidCompletePaymentWithResultArguments = (container: IYandexPayButtonContainer, result: PaymentResult)

    var didCompletePaymentWithResultCallsCount = 0
    var didCompletePaymentWithResultReceivedArguments: DidCompletePaymentWithResultArguments?
    var didCompletePaymentWithResultReceivedInvocations: [DidCompletePaymentWithResultArguments] = []

    func yandexPayButtonContainer(_ container: IYandexPayButtonContainer, didCompletePaymentWithResult result: PaymentResult) {
        didCompletePaymentWithResultCallsCount += 1
        let arguments = (container, result)
        didCompletePaymentWithResultReceivedArguments = arguments
        didCompletePaymentWithResultReceivedInvocations.append(arguments)
    }

    // MARK: - yandexPayButtonContainerDidRequestViewControllerForPresentation

    var yandexPayButtonContainerDidRequestViewControllerForPresentationCallsCount = 0
    var yandexPayButtonContainerDidRequestViewControllerForPresentationReceivedArguments: IYandexPayButtonContainer?
    var yandexPayButtonContainerDidRequestViewControllerForPresentationReceivedInvocations: [IYandexPayButtonContainer] = []
    var yandexPayButtonContainerDidRequestViewControllerForPresentationReturnValue: UIViewController?

    func yandexPayButtonContainerDidRequestViewControllerForPresentation(_ container: IYandexPayButtonContainer) -> UIViewController? {
        yandexPayButtonContainerDidRequestViewControllerForPresentationCallsCount += 1
        let arguments = container
        yandexPayButtonContainerDidRequestViewControllerForPresentationReceivedArguments = arguments
        yandexPayButtonContainerDidRequestViewControllerForPresentationReceivedInvocations.append(arguments)
        return yandexPayButtonContainerDidRequestViewControllerForPresentationReturnValue
    }

    // MARK: - yandexPayButtonContainer

    typealias DidRequestPaymentFlowArguments = (container: IYandexPayButtonContainer, completion: (_ paymentFlow: PaymentFlow?) -> Void)

    var didRequestPaymentFlowCallsCount = 0
    var didRequestPaymentFlowReceivedArguments: DidRequestPaymentFlowArguments?
    var didRequestPaymentFlowReceivedInvocations: [DidRequestPaymentFlowArguments] = []
    var didRequestPaymentFlowCompletionClosureInput: PaymentFlow??

    func yandexPayButtonContainer(_ container: IYandexPayButtonContainer, didRequestPaymentFlow completion: @escaping (_ paymentFlow: PaymentFlow?) -> Void) {
        didRequestPaymentFlowCallsCount += 1
        let arguments = (container, completion)
        didRequestPaymentFlowReceivedArguments = arguments
        didRequestPaymentFlowReceivedInvocations.append(arguments)
        if let didRequestPaymentFlowCompletionClosureInput = didRequestPaymentFlowCompletionClosureInput {
            completion(didRequestPaymentFlowCompletionClosureInput)
        }
    }
}
