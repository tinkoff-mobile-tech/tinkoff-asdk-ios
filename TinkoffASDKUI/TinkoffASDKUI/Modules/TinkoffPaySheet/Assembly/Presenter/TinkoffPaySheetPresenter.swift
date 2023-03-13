//
//  TinkoffPaySheetPresenter.swift
//  TinkoffASDKUI
//
//  Created by r.akhmadeev on 13.03.2023.
//

import Foundation
import TinkoffASDKCore

final class TinkoffPaySheetPresenter {
    // MARK: Dependencies

    weak var view: ICommonSheetView?

    private let router: ITinkoffPaySheetRouter
    private let tinkoffPayService: IAcquiringTinkoffPayService
    private let tinkoffPayController: ITinkoffPayController
    private let paymentFlow: PaymentFlow
    private var moduleCompletion: PaymentResultCompletion?

    // MARK: State

    private var moduleResult: PaymentResult = .cancelled()

    // MARK: Init

    init(
        router: ITinkoffPaySheetRouter,
        tinkoffPayService: IAcquiringTinkoffPayService,
        tinkoffPayController: ITinkoffPayController,
        paymentFlow: PaymentFlow,
        moduleCompletion: PaymentResultCompletion?
    ) {
        self.router = router
        self.tinkoffPayService = tinkoffPayService
        self.tinkoffPayController = tinkoffPayController
        self.paymentFlow = paymentFlow
        self.moduleCompletion = moduleCompletion
    }
}

// MARK: - ICommonSheetPresenter

extension TinkoffPaySheetPresenter: ICommonSheetPresenter {
    func viewDidLoad() {}

    func primaryButtonTapped() {
        view?.close()
    }

    func secondaryButtonTapped() {
        view?.close()
    }

    func canDismissViewByUserInteraction() -> Bool {
        true
    }

    func viewWasClosed() {
        moduleCompletion?(moduleResult)
        moduleCompletion = nil
    }
}

// MARK: - TinkoffPayControllerDelegate

extension TinkoffPaySheetPresenter: TinkoffPayControllerDelegate {
    func tinkoffPayController(
        _ tinkoffPayController: ITinkoffPayController,
        didReceiveIntermediate paymentState: GetPaymentStatePayload
    ) {
        moduleResult = .cancelled(paymentState.toPaymentInfo())
    }

    func tinkoffPayController(
        _ tinkoffPayController: ITinkoffPayController,
        didOpenTinkoffPay url: URL
    ) {}

    func tinkoffPayController(
        _ tinkoffPayController: ITinkoffPayController,
        completedDueToInabilityToOpenTinkoffPay url: URL,
        error: Error
    ) {
        moduleResult = .failed(error)

        router.openTinkoffPayLanding {}
    }

    func tinkoffPayController(
        _ tinkoffPayController: ITinkoffPayController,
        completedWithSuccessful paymentState: GetPaymentStatePayload
    ) {
        moduleResult = .succeeded(paymentState.toPaymentInfo())
    }

    func tinkoffPayController(
        _ tinkoffPayController: ITinkoffPayController,
        completedWithFailed paymentState: GetPaymentStatePayload,
        error: Error
    ) {
        moduleResult = .failed(error)
    }

    func tinkoffPayController(
        _ tinkoffPayController: ITinkoffPayController,
        completedWith error: Error
    ) {
        moduleResult = .failed(error)
    }
}
