//
//  YandexPayPaymentProcess.swift
//  TinkoffASDKUI
//
//  Created by r.akhmadeev on 18.12.2022.
//

import Foundation
import TinkoffASDKCore

final class YandexPayPaymentProcess: PaymentProcess {
    // MARK: PaymentProcess properties

    let paymentFlow: PaymentFlow
    let paymentSource: PaymentSourceData

    var paymentId: String? {
        switch paymentFlow {
        case .full:
            return _paymentId.wrappedValue
        case let .finish(paymentId, _):
            return paymentId
        }
    }

    // MARK: Dependencies

    private let paymentService: IAcquiringPaymentsService
    private let threeDSService: IAcquiringThreeDSService
    private let threeDSDeviceInfoProvider: IThreeDSDeviceInfoProvider
    private weak var delegate: PaymentProcessDelegate?

    // MARK: State

    private let _paymentId: Atomic<String?> = Atomic(wrappedValue: nil)
    private let currentRequest: Atomic<Cancellable?> = Atomic(wrappedValue: nil)
    private let isCancelled: Atomic<Bool> = Atomic(wrappedValue: false)

    // MARK: Init

    init(
        paymentFlow: PaymentFlow,
        paymentSource: PaymentSourceData,
        paymentService: IAcquiringPaymentsService,
        threeDSService: IAcquiringThreeDSService,
        threeDSDeviceInfoProvider: IThreeDSDeviceInfoProvider,
        delegate: PaymentProcessDelegate
    ) {
        self.paymentFlow = paymentFlow
        self.paymentSource = paymentSource
        self.paymentService = paymentService
        self.threeDSService = threeDSService
        self.threeDSDeviceInfoProvider = threeDSDeviceInfoProvider
        self.delegate = delegate
    }

    // MARK: PaymentProcess

    func start() {
        switch paymentFlow {
        case let .full(paymentOptions):
            initPayment(data: .data(with: paymentOptions))
        case let .finish(paymentId, _):
            finishAuthorize(data: createFinishAuthorizeData(paymentId: paymentId))
        }
    }

    func cancel() {
        isCancelled.store(newValue: true)
        currentRequest.wrappedValue?.cancel()
    }
}

// MARK: - Helpers

private extension YandexPayPaymentProcess {
    private func initPayment(data: PaymentInitData) {
        let request = paymentService.initPayment(data: data) { [weak self] result in
            guard let self = self, !self.isCancelled.wrappedValue else { return }

            switch result {
            case let .success(initPayload):
                self._paymentId.store(newValue: initPayload.paymentId)
                self.finishAuthorize(data: self.createFinishAuthorizeData(paymentId: initPayload.paymentId))
            case let .failure(error):
                self.delegate?.paymentDidFailed(self, with: error, cardId: nil, rebillId: nil)
            }
        }

        currentRequest.store(newValue: request)
    }

    private func finishAuthorize(data: FinishAuthorizeData) {
        let request = paymentService.finishAuthorize(data: data) { [weak self] result in
            guard let self = self, !self.isCancelled.wrappedValue else { return }

            switch result {
            case let .success(finishPayload):
                self.handleFinishAuthorize(payload: finishPayload)
            case let .failure(error):
                self.delegate?.paymentDidFailed(self, with: error, cardId: nil, rebillId: nil)
            }
        }

        currentRequest.store(newValue: request)
    }

    private func createFinishAuthorizeData(paymentId: String) -> FinishAuthorizeData {
        FinishAuthorizeData(
            paymentId: paymentId,
            paymentSource: paymentSource,
            infoEmail: paymentFlow.customerOptions?.email,
            deviceInfo: threeDSDeviceInfoProvider.createDeviceInfo(threeDSCompInd: .threeDSCompInd)
        )
    }

    private func handleFinishAuthorize(payload: FinishAuthorizePayload) {
        guard !isCancelled.wrappedValue else { return }

        switch payload.responseStatus {
        case .done:
            handlePaymentResult(.success(payload.paymentState), rebillId: payload.rebillId)
        case let .needConfirmation3DS(data):
            delegate?.payment(
                self,
                need3DSConfirmation: data,
                confirmationCancelled: { [weak self] in self?.handlePaymentCancelled(payload: payload) },
                completion: { [weak self] result in
                    self?.handlePaymentResult(result, rebillId: payload.rebillId)
                }
            )
        case let .needConfirmation3DSACS(data):
            delegate?.payment(
                self,
                need3DSConfirmationACS: data,
                version: .threeDSVersion,
                confirmationCancelled: { [weak self] in self?.handlePaymentCancelled(payload: payload) },
                completion: { [weak self] result in
                    self?.handlePaymentResult(result, rebillId: payload.rebillId)
                }
            )
        case let .needConfirmation3DS2AppBased(data):
            delegate?.payment(
                self,
                need3DSConfirmationAppBased: data,
                version: .threeDSVersion,
                confirmationCancelled: { [weak self] in self?.handlePaymentCancelled(payload: payload) },
                completion: { [weak self] result in
                    self?.handlePaymentResult(result, rebillId: payload.rebillId)
                }
            )
        case .unknown:
            break
        }
    }

    private func handlePaymentCancelled(payload: FinishAuthorizePayload) {
        let cancelledState = GetPaymentStatePayload(
            paymentId: payload.paymentState.paymentId,
            amount: payload.paymentState.amount,
            orderId: payload.paymentState.orderId,
            status: .cancelled
        )

        handlePaymentResult(.success(cancelledState), rebillId: payload.rebillId)
    }

    private func handlePaymentResult(
        _ result: Result<GetPaymentStatePayload, Error>, rebillId: String?
    ) {
        switch result {
        case let .success(payload):
            delegate?.paymentDidFinish(self, with: payload, cardId: nil, rebillId: rebillId)
        case let .failure(error):
            delegate?.paymentDidFailed(self, with: error, cardId: nil, rebillId: rebillId)
        }
    }
}

// MARK: - Constants

private extension String {
    static let threeDSVersion = "2.1.0"
    static let threeDSCompInd = "N"
}

// MARK: PaymentFlow + Helpers

private extension PaymentFlow {
    var customerOptions: CustomerOptions? {
        switch self {
        case let .full(paymentOptions):
            return paymentOptions.customerOptions
        case let .finish(_, customerOptions):
            return customerOptions
        }
    }
}
