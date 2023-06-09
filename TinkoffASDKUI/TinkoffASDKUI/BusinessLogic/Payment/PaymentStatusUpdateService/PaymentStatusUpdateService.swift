//
//  PaymentStatusUpdateService.swift
//  TinkoffASDKUI
//
//  Created by Aleksandr Pravosudov on 09.02.2023.
//

import TinkoffASDKCore

/// Обработка статусов платежей - картой и реккурентов
final class PaymentStatusUpdateService: IPaymentStatusUpdateService {

    // MARK: Dependencies

    weak var delegate: IPaymentStatusUpdateServiceDelegate?

    private let paymentStatusService: IPaymentStatusService
    private let repeatedRequestHelper: IRepeatedRequestHelper
    private let maxRequestRepeatCount: Int

    private lazy var requestRepeatCount = maxRequestRepeatCount

    // MARK: Initialization

    init(
        paymentStatusService: IPaymentStatusService,
        repeatedRequestHelper: IRepeatedRequestHelper,
        maxRequestRepeatCount: Int
    ) {
        self.paymentStatusService = paymentStatusService
        self.repeatedRequestHelper = repeatedRequestHelper
        self.maxRequestRepeatCount = maxRequestRepeatCount
    }
}

// MARK: - IPaymentStatusUpdateService

extension PaymentStatusUpdateService {
    func startUpdateStatusIfNeeded(data: FullPaymentData) {
        requestRepeatCount = maxRequestRepeatCount
        handleStatus(data: data, isRequestRepeatAllowed: requestRepeatCount > 0)
    }
}

// MARK: - Private

extension PaymentStatusUpdateService {
    private func getPaymentStatus(data: FullPaymentData) {
        repeatedRequestHelper.executeWithWaitingIfNeeded { [weak self] in
            guard let self = self else { return }

            self.paymentStatusService.getPaymentState(paymentId: data.payload.paymentId) { result in
                switch result {
                case let .success(payload):
                    self.handleSuccessGetStatus(data: data.update(payload: payload))
                case let .failure(error):
                    self.handleFailureGetStatus(data: data, error: error)
                }
            }
        }
    }

    private func handleSuccessGetStatus(data: FullPaymentData) {
        requestRepeatCount -= 1
        let isRequestRepeatAllowed = requestRepeatCount > 0

        handleStatus(data: data, isRequestRepeatAllowed: isRequestRepeatAllowed)
    }

    private func handleStatus(data: FullPaymentData, isRequestRepeatAllowed: Bool) {
        switch data.payload.status {
        case .cancelled:
            delegate?.paymentCancelStatusRecieved(data: data)
        case .rejected:
            delegate?.paymentFailureStatusRecieved(data: data, error: ASDKError(code: .rejected))
        case .deadlineExpired:
            delegate?.paymentFailureStatusRecieved(data: data, error: ASDKError(.timeout))
        case let status where CardsStatuses.successList.contains(status):
            delegate?.paymentFinalStatusRecieved(data: data)
        case let status where AcquiringStatus.failureList.contains(status):
            delegate?.paymentFailureStatusRecieved(data: data, error: Error)
        default: break
        }

        if isRequestRepeatAllowed {
            /// В остальных случаях дергаем /GetState для получения финального статуса
            getPaymentStatus(data: data)
        } else {
            /// Если исчерпан лимит запросов к GetState и статус все еще не обработан
            /// Показываем ошибку timeout
            delegate?.paymentFailureStatusRecieved(data: data, error: ASDKError(code: .timeout))
        }
    }

    private func handleFailureGetStatus(data: FullPaymentData, error: Error) {
        requestRepeatCount -= 1
        let isRequestRepeatAllowed = requestRepeatCount > 0

        if isRequestRepeatAllowed {
            getPaymentStatus(data: data)
        } else {
            delegate?.paymentFailureStatusRecieved(data: data, error: error)
        }
    }
}

enum CardsStatuses {

    /// Процессные статусы - начало обработки платежа
    static let processingList: [AcquiringStatus] = [
        .preauthorizing,
        .authorizing,
        .paychecking,
    ]

    /// Успешные статусы - платеж успешно совершен
    static let successList: [AcquiringStatus] = [
        .authorized,
        .reversing,
        .partialReversed,
        .reversed,
        .confirming,
        .confirmed,
        .refunding,
        .asyncRefunding,
        .refundedPartial,
        .refunded,
        .cancelRefunded,
        .confirmChecking,
    ]

    /// Статусы ошибок - платеж не совершен
    static let failureList: [AcquiringStatus] = [
        .cancelled,
        .authFail,
        .rejected,
        .deadlineExpired,
        .attemptsExpired,
    ]

    /// Статусы 3DSecure - проверка 3DSecure
    static let threedsList: [AcquiringStatus] = [
        .checking3ds,
        .checked3ds,
    ]
}
