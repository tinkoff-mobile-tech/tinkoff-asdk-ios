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

    private let paymentStatusService: IPaymentStatusService
    private let repeatedRequestHelper: IRepeatedRequestHelper
    private let sbpConfiguration: SBPConfiguration

    // MARK: Properties

    private let paymentId: String

    private lazy var requestRepeatCount: Int = sbpConfiguration.paymentStatusRetriesCount
    private var canDismissView = true

    private var currentViewState: CommonSheetState = .waiting

    // MARK: Initialization

    init(
        paymentStatusService: IPaymentStatusService,
        repeatedRequestHelper: IRepeatedRequestHelper,
        sbpConfiguration: SBPConfiguration,
        paymentId: String
    ) {
        self.paymentStatusService = paymentStatusService
        self.repeatedRequestHelper = repeatedRequestHelper
        self.sbpConfiguration = sbpConfiguration
        self.paymentId = paymentId
    }
}

// MARK: - ICommonSheetPresenter

extension SBPPaymentSheetPresenter {
    func viewDidLoad() {
        getPaymentStatus()
        view?.update(state: currentViewState)
    }

    func primaryButtonTapped() {
        view?.close() // закрываем до шторки выбора оплат если Ошибка при оплате. В других случаях закрываем сдк
    }

    func secondaryButtonTapped() {
        view?.close() // закрываем сдк
    }

    func canDismissViewByUserInteraction() -> Bool {
        canDismissView
    }

    func viewWasClosed() {
        // уведомить о закрытии, передаем в родительское приложение последний статус платежа и как оно закрылось
    }
}

// MARK: - Private

extension SBPPaymentSheetPresenter {
    private func getPaymentStatus() {
        repeatedRequestHelper.executeWithWaitingIfNeeded { [weak self] in
            guard let self = self else { return }

            self.paymentStatusService.getPaymentState(paymentId: self.paymentId) { result in
                DispatchQueue.main.async {
                    switch result {
                    case let .success(payload):
                        self.handleSuccessGet(paymentStatus: payload.status)
                    case .failure:
                        self.handleFailureGetPaymentStatus()
                    }
                }
            }
        }
    }

    private func handleSuccessGet(paymentStatus: PaymentStatus) {
        requestRepeatCount -= 1
        let isRequestRepeatAllowed = requestRepeatCount > 0

        switch paymentStatus {
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
        default: break
        }
    }

    private func handleFailureGetPaymentStatus() {
        requestRepeatCount -= 1
        let isRequestRepeatAllowed = requestRepeatCount > 0
        if isRequestRepeatAllowed {
            getPaymentStatus()
        } else {
            canDismissView = true
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
