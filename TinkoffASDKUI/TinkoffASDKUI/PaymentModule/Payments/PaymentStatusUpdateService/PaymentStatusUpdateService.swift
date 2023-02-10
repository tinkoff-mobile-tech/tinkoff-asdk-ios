//
//  PaymentStatusUpdateService.swift
//  TinkoffASDKUI
//
//  Created by Aleksandr Pravosudov on 09.02.2023.
//

import TinkoffASDKCore

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
        case .authorized, .confirmed:
            delegate?.paymentFinalStatusRecieved(data: data)
            return
        case .rejected:
            delegate?.paymentFailureStatusRecieved(data: data, error: ASDKError(code: .rejected))
        case .deadlineExpired:
            delegate?.paymentFailureStatusRecieved(data: data, error: ASDKError(code: .timeout))
        case .cancelled:
            delegate?.paymentCancelStatusRecieved(data: data)
            return
        default: break
        }

        if isRequestRepeatAllowed {
            getPaymentStatus(data: data)
        } else {
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
