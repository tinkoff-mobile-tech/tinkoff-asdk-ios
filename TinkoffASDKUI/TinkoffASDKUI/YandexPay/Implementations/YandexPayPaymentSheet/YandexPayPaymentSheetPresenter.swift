//
//  YandexPayPaymentSheetPresenter.swift
//  TinkoffASDKUI
//
//  Created by r.akhmadeev on 12.12.2022.
//

import Foundation
import TinkoffASDKCore

final class YandexPayPaymentSheetPresenter {
    // MARK: Dependencies

    weak var view: ICommonSheetView?
    private weak var output: IYandexPayPaymentSheetOutput?
    private let paymentController: IPaymentController
    private let paymentControllerUIProvider: PaymentControllerUIProvider
    private let paymentFlow: PaymentFlow
    private let base64Token: String

    // MARK: State

    private var paymentResult: PaymentResult = .cancelled()
    private var canDismissView = false

    // MARK: Init

    init(
        paymentController: IPaymentController,
        paymentControllerUIProvider: PaymentControllerUIProvider,
        paymentFlow: PaymentFlow,
        base64Token: String,
        output: IYandexPayPaymentSheetOutput
    ) {
        self.paymentController = paymentController
        self.paymentControllerUIProvider = paymentControllerUIProvider
        self.paymentFlow = paymentFlow
        self.base64Token = base64Token
        self.output = output
    }
}

// MARK: - ICommonSheetPresenter

extension YandexPayPaymentSheetPresenter: ICommonSheetPresenter {
    func viewDidLoad() {
        view?.update(state: .processing)

        paymentController.performPayment(
            paymentFlow: paymentFlow,
            paymentSource: .yandexPay(base64Token: base64Token)
        )
    }

    func primaryButtonTapped() {
        view?.close()
    }

    func secondaryButtonTapped() {}

    func canDismissViewByUserInteraction() -> Bool {
        canDismissView
    }

    func viewWasClosed() {
        output?.yandexPayPaymentActivity(completedWith: paymentResult)
    }
}

// MARK: - PaymentControllerDelegate

extension YandexPayPaymentSheetPresenter: PaymentControllerDelegate {
    func paymentController(
        _ controller: PaymentController,
        didFinishPayment: PaymentProcess,
        with state: TinkoffASDKCore.GetPaymentStatePayload,
        cardId: String?,
        rebillId: String?
    ) {
        let paymentInfo = PaymentResult.PaymentInfo(
            paymentId: state.paymentId,
            orderId: state.orderId,
            amount: state.amount,
            paymentStatus: state.status
        )

        paymentResult = .succeeded(paymentInfo)
        canDismissView = true
        view?.update(state: .paid)
    }

    func paymentController(
        _ controller: PaymentController,
        paymentWasCancelled: PaymentProcess,
        cardId: String?,
        rebillId: String?
    ) {
        paymentResult = .cancelled()
        canDismissView = true
        view?.close()
    }

    func paymentController(
        _ controller: PaymentController,
        didFailed error: Error,
        cardId: String?,
        rebillId: String?
    ) {
        paymentResult = .failed(error)
        canDismissView = true
        view?.update(state: .failed)
    }
}

// MARK: - CommonSheetState + YandexPay States

private extension CommonSheetState {
    static var processing: CommonSheetState {
        CommonSheetState(
            status: .processing,
            title: Loc.CommonSheet.Processing.title,
            description: Loc.CommonSheet.Processing.description
        )
    }

    static var paid: CommonSheetState {
        CommonSheetState(
            status: .succeeded,
            title: Loc.CommonSheet.Paid.title,
            primaryButtonTitle: Loc.CommonSheet.Paid.primaryButton
        )
    }

    static var failed: CommonSheetState {
        CommonSheetState(
            status: .failed,
            title: Loc.YandexSheet.Failed.title,
            description: Loc.YandexSheet.Failed.description,
            primaryButtonTitle: Loc.YandexSheet.Failed.primaryButton
        )
    }
}
