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

    weak var view: ICommonSheetViewInput?
    private weak var output: IYandexPayPaymentSheetOutput?
    private let paymentController: IPaymentController
    private let paymentControllerUIProvider: PaymentControllerUIProvider
    private let paymentOptions: PaymentOptions
    private let base64Token: String

    // MARK: State

    private var paymentResult: YandexPayPaymentResult = .cancelled

    // MARK: Init

    init(
        paymentController: IPaymentController,
        paymentControllerUIProvider: PaymentControllerUIProvider,
        paymentOptions: PaymentOptions,
        base64Token: String,
        output: IYandexPayPaymentSheetOutput
    ) {
        self.paymentController = paymentController
        self.paymentControllerUIProvider = paymentControllerUIProvider
        self.paymentOptions = paymentOptions
        self.base64Token = base64Token
        self.output = output
    }
}

// MARK: - ICommonSheetViewOutput

extension YandexPayPaymentSheetPresenter: ICommonSheetViewOutput {
    func viewDidLoad() {
        view?.update(state: .processing)

        paymentController.performInitPayment(
            paymentOptions: paymentOptions,
            paymentSource: .yandexPay(base64Token: base64Token)
        )
    }

    func primaryButtonTapped() {
        view?.close()
    }

    func secondaryButtonTapped() {}

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
        let paymentInfo = YandexPayPaymentResult.PaymentInfo(
            paymentOptions: paymentOptions,
            paymentId: state.paymentId
        )
        paymentResult = .succeeded(paymentInfo)
        view?.update(state: .paid)
    }

    func paymentController(
        _ controller: PaymentController,
        paymentWasCancelled: PaymentProcess,
        cardId: String?,
        rebillId: String?
    ) {
        paymentResult = .cancelled
        view?.close()
    }

    func paymentController(
        _ controller: PaymentController,
        didFailed error: Error,
        cardId: String?,
        rebillId: String?
    ) {
        paymentResult = .failed(error)
        view?.update(state: .failed)
    }
}

// MARK: - CommonSheetState + YandexPay States

private extension CommonSheetState {
    static var processing: CommonSheetState {
        CommonSheetState(
            status: .processing,
            title: Loc.CommonSheet.Processing.title,
            description: Loc.CommonSheet.Processing.description,
            dismissionAllowed: false
        )
    }

    static var paid: CommonSheetState {
        CommonSheetState(
            status: .succeeded,
            title: Loc.CommonSheet.Paid.title,
            primaryButtonTitle: Loc.CommonSheet.Paid.primaryButton,
            dismissionAllowed: true
        )
    }

    static var failed: CommonSheetState {
        CommonSheetState(
            status: .failed,
            title: Loc.YandexSheet.Failed.title,
            description: Loc.YandexSheet.Failed.description,
            primaryButtonTitle: Loc.YandexSheet.Failed.primaryButton,
            dismissionAllowed: true
        )
    }
}
