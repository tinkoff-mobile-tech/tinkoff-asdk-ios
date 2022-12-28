//
//  YandexPayPaymentActivityPresenter.swift
//  TinkoffASDKUI
//
//  Created by r.akhmadeev on 12.12.2022.
//

import Foundation
import TinkoffASDKCore

final class YandexPayPaymentActivityPresenter {
    // MARK: Dependencies

    weak var view: IPaymentActivityViewInput?
    private weak var output: IYandexPayPaymentActivityOutput?
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
        output: IYandexPayPaymentActivityOutput
    ) {
        self.paymentController = paymentController
        self.paymentControllerUIProvider = paymentControllerUIProvider
        self.paymentOptions = paymentOptions
        self.base64Token = base64Token
        self.output = output
    }
}

// MARK: - IPaymentActivityViewOutput

extension YandexPayPaymentActivityPresenter: IPaymentActivityViewOutput {
    func viewDidLoad() {
        view?.update(with: .processing, animated: false)

        paymentController.performInitPayment(
            paymentOptions: paymentOptions,
            paymentSource: .yandexPay(base64Token: base64Token)
        )
    }

    func primaryButtonTapped() {
        view?.close()
    }

    func viewWasClosed() {
        output?.yandexPayPaymentActivity(completedWith: paymentResult)
    }
}

// MARK: - PaymentControllerDelegate

extension YandexPayPaymentActivityPresenter: PaymentControllerDelegate {
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
        view?.update(with: .paid, animated: true)
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
        view?.update(with: .failed, animated: true)
    }
}

// MARK: - PaymentActivityViewState + YandexPayPaymentActivity States

private extension PaymentActivityViewState {
    static var processing: PaymentActivityViewState {
        .processing(
            Processing(
                title: Loc.CommonSheet.Processing.title,
                description: Loc.CommonSheet.Processing.description
            )
        )
    }

    static var paid: PaymentActivityViewState {
        .processed(
            Processed(
                image: Asset.TuiIcMedium.checkCirclePositive.image,
                title: Loc.CommonSheet.Paid.title,
                primaryButtonTitle: Loc.CommonSheet.Paid.primaryButton
            )
        )
    }

    static var failed: PaymentActivityViewState {
        .processed(
            Processed(
                image: Asset.TuiIcMedium.crossCircle.image,
                title: Loc.YandexSheet.Failed.title,
                description: Loc.YandexSheet.Failed.description,
                primaryButtonTitle: Loc.YandexSheet.Failed.primaryButton
            )
        )
    }
}
