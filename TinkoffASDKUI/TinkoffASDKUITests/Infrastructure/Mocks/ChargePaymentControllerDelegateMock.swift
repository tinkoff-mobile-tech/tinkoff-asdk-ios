//
//  ChargePaymentControllerDelegateMock.swift
//  TinkoffASDKUI-Unit-Tests
//
//  Created by Никита Васильев on 22.06.2023.
//

import TinkoffASDKCore
import TinkoffASDKUI

final class ChargePaymentControllerDelegateMock: ChargePaymentControllerDelegate {
    // MARK: - paymentController

    struct DidFinishPaymentPassedArguments {
        let controller: IPaymentController
        let didFinishPayment: IPaymentProcess
        let state: GetPaymentStatePayload
        let cardId: String?
        let rebillId: String?
    }

    var paymentControllerDidFinishPaymentCallCounter = 0
    var paymentControllerDidFinishPaymentReturnStub: (DidFinishPaymentPassedArguments) -> Void = { _ in }

    func paymentController(
        _ controller: IPaymentController,
        didFinishPayment: IPaymentProcess,
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
        let paymentWasCancelled: IPaymentProcess
        let cardId: String?
        let rebillId: String?
    }

    var paymentControllerPaymentWasCancelledCallCounter = 0
    var paymentControllerPaymentWasCancelledReturnStub: (WasCancelledPassedArguments) -> Void = { _ in }

    func paymentController(
        _ controller: IPaymentController,
        paymentWasCancelled: IPaymentProcess,
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

    struct ShouldRepeatWithRebillIdArgumentd {
        let controller: IPaymentController
        let failedPaymentProcess: IPaymentProcess
        let rebillId: String?
        let additionalData: [String: String]
        let error: Error
    }

    var paymentControllerShouldRepeatWithRebillIdCallCounter = 0
    var paymentControllerShouldRepeatWithRebillIdReturnParameters: (data: ShouldRepeatWithRebillIdArgumentd, Void)?
    var paymentControllerShouldRepeatWithRebillIdReturnStub: (ShouldRepeatWithRebillIdArgumentd) -> Void = { _ in }

    func paymentController(
        _ controller: IPaymentController,
        shouldRepeatWithRebillId rebillId: String,
        failedPaymentProcess: IPaymentProcess,
        additionalData: [String: String],
        error: Error
    ) {
        let data = ShouldRepeatWithRebillIdArgumentd(
            controller: controller,
            failedPaymentProcess: failedPaymentProcess,
            rebillId: rebillId,
            additionalData: additionalData,
            error: error
        )

        paymentControllerShouldRepeatWithRebillIdCallCounter += 1
        paymentControllerShouldRepeatWithRebillIdReturnParameters = (data, ())
        paymentControllerShouldRepeatWithRebillIdReturnStub(data)
    }
}
