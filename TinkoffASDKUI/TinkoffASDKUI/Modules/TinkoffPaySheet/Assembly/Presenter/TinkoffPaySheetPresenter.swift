//
//  TinkoffPaySheetPresenter.swift
//  TinkoffASDKUI
//
//  Created by r.akhmadeev on 13.03.2023.
//

import Foundation
import TinkoffASDKCore

final class TinkoffPaySheetPresenter {
    // MARK: Internal Types

    enum Error: Swift.Error {
        case tinkoffPayIsNotAllowed
    }

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
    func viewDidLoad() {
        let handleFailure: (Swift.Error) -> Void = { [weak self] error in
            self?.moduleResult = .failed(error)
            self?.view?.update(state: .tinkoffPay.failedPaymentOnIndependentFlow)
        }

        let handleSuccess: (GetTinkoffPayStatusPayload) -> Void = { [weak self] payload in
            guard let self = self else { return }

            switch payload.status {
            case let .allowed(method):
                self.tinkoffPayController.performPayment(paymentFlow: self.paymentFlow, method: method)
            case .disallowed:
                handleFailure(Error.tinkoffPayIsNotAllowed)
            }
        }

        view?.update(state: .tinkoffPay.processing)

        tinkoffPayService.getTinkoffPayStatus { result in
            DispatchQueue.performOnMain {
                switch result {
                case let .success(payload):
                    handleSuccess(payload)
                case let .failure(error):
                    handleFailure(error)
                }
            }
        }
    }

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
        completedDueToInabilityToOpenTinkoffPay url: URL,
        error: Swift.Error
    ) {
        moduleResult = .failed(error)

        router.openTinkoffPayLanding { [weak self] in
            self?.view?.update(state: .tinkoffPay.failedPaymentOnIndependentFlow)
        }
    }

    func tinkoffPayController(
        _ tinkoffPayController: ITinkoffPayController,
        completedWithSuccessful paymentState: GetPaymentStatePayload
    ) {
        moduleResult = .succeeded(paymentState.toPaymentInfo())
        view?.update(state: .tinkoffPay.paid)
    }

    func tinkoffPayController(
        _ tinkoffPayController: ITinkoffPayController,
        completedWithFailed paymentState: GetPaymentStatePayload,
        error: Swift.Error
    ) {
        moduleResult = .failed(error)
        view?.update(state: .tinkoffPay.failedPaymentOnIndependentFlow)
    }

    func tinkoffPayController(
        _ tinkoffPayController: ITinkoffPayController,
        completedWithTimeout paymentState: GetPaymentStatePayload,
        error: Swift.Error
    ) {
        moduleResult = .failed(error)
        view?.update(state: .tinkoffPay.timedOut)
    }

    func tinkoffPayController(
        _ tinkoffPayController: ITinkoffPayController,
        completedWith error: Swift.Error
    ) {
        moduleResult = .failed(error)
        view?.update(state: .tinkoffPay.failedPaymentOnIndependentFlow)
    }
}
