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
    private let paymentControllerUIProvider: any ThreeDSWebFlowDelegate
    private let paymentFlow: PaymentFlow
    private let base64Token: String

    // MARK: State

    private var paymentResult: PaymentResult = .cancelled()
    private var canDismissView = false

    // MARK: Init

    init(
        paymentController: IPaymentController,
        paymentControllerUIProvider: any ThreeDSWebFlowDelegate,
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
        view?.update(state: SheetState.processing.toCommonSheetState(), animatePullableContainerUpdates: false)

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
        output?.yandexPayPaymentSheet(completedWith: paymentResult)
    }
}

// MARK: - PaymentControllerDelegate

extension YandexPayPaymentSheetPresenter: PaymentControllerDelegate {
    func paymentController(
        _ controller: IPaymentController,
        didFinishPayment: IPaymentProcess,
        with state: TinkoffASDKCore.GetPaymentStatePayload,
        cardId: String?,
        rebillId: String?
    ) {
        let paymentInfo = state.toPaymentInfo()
        paymentResult = .succeeded(paymentInfo)
        canDismissView = true
        view?.update(state: SheetState.paid.toCommonSheetState())
    }

    func paymentController(
        _ controller: IPaymentController,
        paymentWasCancelled: IPaymentProcess,
        cardId: String?,
        rebillId: String?
    ) {
        paymentResult = .cancelled()
        canDismissView = true
        view?.close()
    }

    func paymentController(
        _ controller: IPaymentController,
        didFailed error: Error,
        cardId: String?,
        rebillId: String?
    ) {
        paymentResult = .failed(error)
        canDismissView = true
        view?.update(state: SheetState.failed.toCommonSheetState())
    }
}

// MARK: - SheetState + CommonSheetState

extension YandexPayPaymentSheetPresenter {

    enum SheetState {
        case processing
        case paid
        case failed

        func toCommonSheetState() -> CommonSheetState {
            switch self {
            case .processing:
                return CommonSheetState(
                    status: .processing,
                    title: Loc.CommonSheet.Processing.title,
                    description: Loc.CommonSheet.Processing.description
                )

            case .paid:
                return CommonSheetState(
                    status: .succeeded,
                    title: Loc.CommonSheet.Paid.title,
                    primaryButtonTitle: Loc.CommonSheet.Paid.primaryButton
                )

            case .failed:
                return CommonSheetState(
                    status: .failed,
                    title: Loc.YandexSheet.Failed.title,
                    description: Loc.YandexSheet.Failed.description,
                    primaryButtonTitle: Loc.YandexSheet.Failed.primaryButton
                )
            }
        }
    }
}
