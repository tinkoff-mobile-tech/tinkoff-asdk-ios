//
//
//  ChargePaymentProcess.swift
//
//  Copyright (c) 2021 Tinkoff Bank
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//   http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import TinkoffASDKCore

final class ChargePaymentProcess: IPaymentProcess {
    private let paymentsService: IAcquiringPaymentsService
    private var isCancelled = Atomic(wrappedValue: false)
    private var currentRequest: Atomic<Cancellable>?

    let paymentSource: PaymentSourceData
    let paymentFlow: PaymentFlow
    private(set) var paymentId: String?

    private weak var delegate: PaymentProcessDelegate?

    init(
        paymentsService: IAcquiringPaymentsService,
        paymentSource: PaymentSourceData,
        paymentFlow: PaymentFlow,
        delegate: PaymentProcessDelegate
    ) {
        self.paymentsService = paymentsService
        self.paymentSource = paymentSource
        self.paymentFlow = paymentFlow
        self.delegate = delegate
    }

    func start() {
        switch paymentFlow {
        case let .full(paymentOptions):
            initPayment(data: PaymentInitData.data(with: paymentOptions, isCharge: true))
        case let .finish(paymentOptions):
            paymentId = paymentOptions.paymentId
            finishPayment(paymentId: paymentOptions.paymentId)
        }
    }

    func cancel() {
        isCancelled.store(newValue: true)
        currentRequest?.wrappedValue.cancel()
    }
}

private extension ChargePaymentProcess {
    func initPayment(data: PaymentInitData) {
        let request = paymentsService.initPayment(data: data) { [weak self] result in
            guard let self = self else { return }
            guard !self.isCancelled.wrappedValue else { return }

            switch result {
            case let .success(payload):
                self.handleInitResult(payload: payload)
            case let .failure(error):
                self.handleError(error: error)
            }
        }
        currentRequest?.store(newValue: request)
    }

    func finishPayment(paymentId: String) {
        performCharge(
            data: ChargeData(
                paymentId: paymentId,
                rebillId: getRebillId()
            )
        )
    }

    func performCharge(data: ChargeData) {

        let request = paymentsService.charge(data: data) { [weak self] result in
            guard let self = self else { return }
            guard !self.isCancelled.wrappedValue else { return }

            switch result {
            case let .success(payload):
                self.handleChargeResult(payload: payload)
            case let .failure(error):
                self.handleError(error: error)
            }
        }
        currentRequest?.store(newValue: request)
    }

    func handleInitResult(payload: InitPayload) {
        paymentId = payload.paymentId
        performCharge(
            data: ChargeData(
                paymentId: payload.paymentId,
                rebillId: getRebillId()
            )
        )
    }

    func handleChargeResult(payload: ChargePayload) {
        guard !isCancelled.wrappedValue else { return }

        let (cardId, rebillId) = paymentSource.getCardAndRebillId()
        delegate?.paymentDidFinish(
            self,
            with: payload.paymentState,
            cardId: cardId,
            rebillId: rebillId
        )
    }

    func handleError(error: Error) {
        let (cardId, rebillId) = paymentSource.getCardAndRebillId()
        delegate?.paymentDidFailed(self, with: error, cardId: cardId, rebillId: rebillId)
    }

    func getRebillId() -> String {
        switch paymentSource {
        case let .parentPayment(rebillId):
            return rebillId
        default:
            // Log error
            assertionFailure("Only parentPayment PaymentSourceData available")
            return ""
        }
    }
}
