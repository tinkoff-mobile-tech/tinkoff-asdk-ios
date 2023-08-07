//
//  ChargePaymentControllerDelegateMock.swift
//  TinkoffASDKUI-Unit-Tests
//
//  Created by Никита Васильев on 22.06.2023.
//

import TinkoffASDKCore
import TinkoffASDKUI

final class ChargePaymentControllerDelegateMock: ChargePaymentControllerDelegate {

    // MARK: - paymentControllerShouldRepeatWithRebillId

    typealias PaymentControllerShouldRepeatWithRebillIdArguments = (controller: IPaymentController, rebillId: String, failedPaymentProcess: IPaymentProcess, additionalInitData: AdditionalData?, error: Error)

    var paymentControllerShouldRepeatWithRebillIdCallsCount = 0
    var paymentControllerShouldRepeatWithRebillIdReceivedArguments: PaymentControllerShouldRepeatWithRebillIdArguments?
    var paymentControllerShouldRepeatWithRebillIdReceivedInvocations: [PaymentControllerShouldRepeatWithRebillIdArguments?] = []

    func paymentController(_ controller: IPaymentController, shouldRepeatWithRebillId rebillId: String, failedPaymentProcess: IPaymentProcess, additionalInitData: AdditionalData?, error: Error) {
        paymentControllerShouldRepeatWithRebillIdCallsCount += 1
        let arguments = (controller, rebillId, failedPaymentProcess, additionalInitData, error)
        paymentControllerShouldRepeatWithRebillIdReceivedArguments = arguments
        paymentControllerShouldRepeatWithRebillIdReceivedInvocations.append(arguments)
    }

    // MARK: - paymentControllerDidFinishPayment

    typealias PaymentControllerDidFinishPaymentArguments = (controller: IPaymentController, paymentProcess: IPaymentProcess, state: GetPaymentStatePayload, cardId: String?, rebillId: String?)

    var paymentControllerDidFinishPaymentCallsCount = 0
    var paymentControllerDidFinishPaymentReceivedArguments: PaymentControllerDidFinishPaymentArguments?
    var paymentControllerDidFinishPaymentReceivedInvocations: [PaymentControllerDidFinishPaymentArguments?] = []

    func paymentController(_ controller: IPaymentController, didFinishPayment paymentProcess: IPaymentProcess, with state: GetPaymentStatePayload, cardId: String?, rebillId: String?) {
        paymentControllerDidFinishPaymentCallsCount += 1
        let arguments = (controller, paymentProcess, state, cardId, rebillId)
        paymentControllerDidFinishPaymentReceivedArguments = arguments
        paymentControllerDidFinishPaymentReceivedInvocations.append(arguments)
    }

    // MARK: - paymentControllerPaymentWasCancelled

    typealias PaymentControllerPaymentWasCancelledArguments = (controller: IPaymentController, paymentProcess: IPaymentProcess, cardId: String?, rebillId: String?)

    var paymentControllerPaymentWasCancelledCallsCount = 0
    var paymentControllerPaymentWasCancelledReceivedArguments: PaymentControllerPaymentWasCancelledArguments?
    var paymentControllerPaymentWasCancelledReceivedInvocations: [PaymentControllerPaymentWasCancelledArguments?] = []

    func paymentController(_ controller: IPaymentController, paymentWasCancelled paymentProcess: IPaymentProcess, cardId: String?, rebillId: String?) {
        paymentControllerPaymentWasCancelledCallsCount += 1
        let arguments = (controller, paymentProcess, cardId, rebillId)
        paymentControllerPaymentWasCancelledReceivedArguments = arguments
        paymentControllerPaymentWasCancelledReceivedInvocations.append(arguments)
    }

    // MARK: - paymentControllerDidFailed

    typealias PaymentControllerDidFailedArguments = (controller: IPaymentController, error: Error, cardId: String?, rebillId: String?)

    var paymentControllerDidFailedCallsCount = 0
    var paymentControllerDidFailedReceivedArguments: PaymentControllerDidFailedArguments?
    var paymentControllerDidFailedReceivedInvocations: [PaymentControllerDidFailedArguments?] = []

    func paymentController(_ controller: IPaymentController, didFailed error: Error, cardId: String?, rebillId: String?) {
        paymentControllerDidFailedCallsCount += 1
        let arguments = (controller, error, cardId, rebillId)
        paymentControllerDidFailedReceivedArguments = arguments
        paymentControllerDidFailedReceivedInvocations.append(arguments)
    }
}

// MARK: - Resets

extension ChargePaymentControllerDelegateMock {
    func fullReset() {
        paymentControllerShouldRepeatWithRebillIdCallsCount = 0
        paymentControllerShouldRepeatWithRebillIdReceivedArguments = nil
        paymentControllerShouldRepeatWithRebillIdReceivedInvocations = []

        paymentControllerDidFinishPaymentCallsCount = 0
        paymentControllerDidFinishPaymentReceivedArguments = nil
        paymentControllerDidFinishPaymentReceivedInvocations = []

        paymentControllerPaymentWasCancelledCallsCount = 0
        paymentControllerPaymentWasCancelledReceivedArguments = nil
        paymentControllerPaymentWasCancelledReceivedInvocations = []

        paymentControllerDidFailedCallsCount = 0
        paymentControllerDidFailedReceivedArguments = nil
        paymentControllerDidFailedReceivedInvocations = []
    }
}
