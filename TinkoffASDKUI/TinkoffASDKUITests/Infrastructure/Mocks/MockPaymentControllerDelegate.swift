//
//  MockPaymentControllerDelegate.swift
//  TinkoffASDKUI-Unit-Tests
//
//  Created by Ivan Glushko on 21.10.2022.
//

import TinkoffASDKCore
@testable import TinkoffASDKUI

final class MockPaymentControllerDelegate: PaymentControllerDelegate {
    // MARK: - paymentController

    struct DidFinishPaymentPassedArguments {
        let controller: IPaymentController
        let didFinishPayment: PaymentProcess
        let state: GetPaymentStatePayload
        let cardId: String?
        let rebillId: String?
    }

    var paymentControllerDidFinishPaymentCallCounter = 0
    var paymentControllerDidFinishPaymentReturnStub: (DidFinishPaymentPassedArguments) -> Void = { _ in }

    func paymentController(
        _ controller: IPaymentController,
        didFinishPayment: PaymentProcess,
        with state: GetPaymentStatePayload,
        cardId: String?,
        rebillId: String?
    ) {
        paymentControllerDidFinishPaymentCallCounter += 1
        let args = DidFinishPaymentPassedArguments(
            controller: controller,
            didFinishPayment: didFinishPayment,
            state: state,
            cardId: cardId,
            rebillId: rebillId
        )
        paymentControllerDidFinishPaymentReturnStub(args)
    }

    // MARK: - paymentController

    struct WasCancelledPassedArguments {
        let controller: IPaymentController
        let paymentWasCancelled: PaymentProcess
        let cardId: String?
        let rebillId: String?
    }

    var paymentControllerPaymentWasCancelledCallCounter = 0
    var paymentControllerPaymentWasCancelledReturnStub: (WasCancelledPassedArguments) -> Void = { _ in }

    func paymentController(
        _ controller: IPaymentController,
        paymentWasCancelled: PaymentProcess,
        cardId: String?,
        rebillId: String?
    ) {
        paymentControllerPaymentWasCancelledCallCounter += 1
        paymentControllerPaymentWasCancelledReturnStub(
            WasCancelledPassedArguments(
                controller: controller,
                paymentWasCancelled: paymentWasCancelled,
                cardId: cardId,
                rebillId: rebillId
            )
        )
    }

    // MARK: - paymentController

    struct DidFailedPassedArguments {
        let controller: IPaymentController
        let didFailedError: Error
        let cardId: String?
        let rebillId: String?
    }

    var paymentControllerDidFailedCallCounter = 0
    var paymentControllerDidFailedReturnStub: (DidFailedPassedArguments) -> Void = { _ in }

    func paymentController(
        _ controller: IPaymentController,
        didFailed error: Error,
        cardId: String?,
        rebillId: String?
    ) {
        paymentControllerDidFailedCallCounter += 1
        paymentControllerDidFailedReturnStub(
            DidFailedPassedArguments(
                controller: controller,
                didFailedError: error,
                cardId: cardId,
                rebillId: rebillId
            )
        )
    }
}
