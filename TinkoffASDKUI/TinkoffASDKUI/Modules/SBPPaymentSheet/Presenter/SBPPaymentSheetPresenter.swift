//
//  SBPPaymentSheetPresenter.swift
//  TinkoffASDKUI
//
//  Created by Aleksandr Pravosudov on 17.01.2023.
//

import Foundation
import TinkoffASDKCore

/// Презентер для управления платежной шторкой в разделе СБП
/// После показа, начинается повторяющаяся серия запросов для получения статуса с интервалом в 3 секунды
/// Количество таких запросов `requestRepeatCount` по умолчанию установленно в 10, мерч может сам установить этот параметр как ему хочется
final class SBPPaymentSheetPresenter: ICommonSheetPresenter {

    // MARK: Dependencies

    weak var view: ICommonSheetView?

    private weak var output: ISBPPaymentSheetPresenterOutput?

    private let paymentStatusService: IPaymentStatusService
    private let repeatedRequestHelper: IRepeatedRequestHelper
    private let mainDispatchQueue: IDispatchQueue

    // MARK: Properties

    private let paymentId: String
    private var requestRepeatCount: Int
    private var canDismissView = true

    private var currentViewState: CommonSheetState = .waiting
    private var lastPaymentInfo: PaymentResult.PaymentInfo?
    private var lastGetPaymentStatusError: Error?

    // MARK: Initialization

    init(
        output: ISBPPaymentSheetPresenterOutput?,
        paymentStatusService: IPaymentStatusService,
        repeatedRequestHelper: IRepeatedRequestHelper,
        mainDispatchQueue: IDispatchQueue,
        requestRepeatCount: Int,
        paymentId: String
    ) {
        self.output = output
        self.paymentStatusService = paymentStatusService
        self.repeatedRequestHelper = repeatedRequestHelper
        self.requestRepeatCount = requestRepeatCount
        self.mainDispatchQueue = mainDispatchQueue
        self.paymentId = paymentId
    }
}

// MARK: - ICommonSheetPresenter

extension SBPPaymentSheetPresenter {
    func viewDidLoad() {
        getPaymentStatus()
        view?.update(state: currentViewState, animatePullableContainerUpdates: false)
    }

    func primaryButtonTapped() {
        view?.close()
    }

    func secondaryButtonTapped() {
        view?.close()
    }

    func canDismissViewByUserInteraction() -> Bool {
        canDismissView
    }

    func viewWasClosed() {
        switch currentViewState {
        case .paid:
            guard let lastPaymentInfo = lastPaymentInfo else {
                output?.sbpPaymentSheet(completedWith: .failed(ASDKError(code: .unknown)))
                return
            }

            output?.sbpPaymentSheet(completedWith: .succeeded(lastPaymentInfo))
        case .waiting:
            output?.sbpPaymentSheet(completedWith: .cancelled(lastPaymentInfo))
        case .paymentFailed:
            output?.sbpPaymentSheet(completedWith: .failed(ASDKError(code: .rejected)))
        case .timeout:
            output?.sbpPaymentSheet(completedWith: .failed(ASDKError(code: .timeout, underlyingError: lastGetPaymentStatusError)))
        default:
            // во всех остальных кейсах, закрытие шторки должно быть невозможно
            break
        }
    }
}

// MARK: - Private

extension SBPPaymentSheetPresenter {
    private func getPaymentStatus() {
        repeatedRequestHelper.executeWithWaitingIfNeeded { [weak self] in
            guard let self = self else { return }

            self.paymentStatusService.getPaymentState(paymentId: self.paymentId) { [weak self] result in
                self?.mainDispatchQueue.async {
                    switch result {
                    case let .success(payload):
                        self?.handleSuccessGet(payloadInfo: payload)
                    case let .failure(error):
                        self?.handleFailureGetPaymentStatus(error)
                    }
                }
            }
        }
    }

    private func handleSuccessGet(payloadInfo: GetPaymentStatePayload) {
        lastPaymentInfo = payloadInfo.toPaymentInfo()

        requestRepeatCount -= 1
        let isRequestRepeatAllowed = requestRepeatCount > 0

        switch payloadInfo.status {
        case .formShowed where isRequestRepeatAllowed:
            canDismissView = true
            getPaymentStatus()
            viewUpdateStateIfNeeded(newState: .waiting)
        case .formShowed where !isRequestRepeatAllowed:
            canDismissView = true
            viewUpdateStateIfNeeded(newState: .timeout)
        case .authorizing, .confirming:
            canDismissView = false
            getPaymentStatus()
            viewUpdateStateIfNeeded(newState: .processing)
        case .authorized, .confirmed:
            canDismissView = true
            viewUpdateStateIfNeeded(newState: .paid)
        case .rejected:
            canDismissView = true
            viewUpdateStateIfNeeded(newState: .paymentFailed)
        case .deadlineExpired:
            canDismissView = true
            viewUpdateStateIfNeeded(newState: .timeout)
        default:
            canDismissView = true
            viewUpdateStateIfNeeded(newState: .paymentFailed)
        }
    }

    private func handleFailureGetPaymentStatus(_ error: Error) {
        requestRepeatCount -= 1
        let isRequestRepeatAllowed = requestRepeatCount > 0
        if isRequestRepeatAllowed {
            getPaymentStatus()
        } else {
            canDismissView = true
            lastGetPaymentStatusError = error
            viewUpdateStateIfNeeded(newState: .timeout)
        }
    }

    private func viewUpdateStateIfNeeded(newState: CommonSheetState) {
        if currentViewState != newState {
            currentViewState = newState
            view?.update(state: currentViewState)
        }
    }
}

// MARK: - CommonSheetState + SBP States

private extension CommonSheetState {
    static var waiting: CommonSheetState {
        CommonSheetState(
            status: .processing,
            title: Loc.CommonSheet.PaymentWaiting.title,
            secondaryButtonTitle: Loc.CommonSheet.PaymentWaiting.secondaryButton
        )
    }

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

    static var timeout: CommonSheetState {
        CommonSheetState(
            status: .failed,
            title: Loc.CommonSheet.TimeoutFailed.title,
            description: Loc.CommonSheet.TimeoutFailed.description,
            secondaryButtonTitle: Loc.CommonSheet.TimeoutFailed.secondaryButton
        )
    }

    static var paymentFailed: CommonSheetState {
        CommonSheetState(
            status: .failed,
            title: Loc.CommonSheet.PaymentFailed.title,
            description: Loc.CommonSheet.PaymentFailed.description,
            primaryButtonTitle: Loc.CommonSheet.PaymentFailed.primaryButton
        )
    }
}
