//
//  TinkoffPayController.swift
//  TinkoffASDKUI
//
//  Created by r.akhmadeev on 02.03.2023.
//

import Foundation
import TinkoffASDKCore

final class TinkoffPayController: ITinkoffPayController {
    // MARK: Internal Types

    enum Error: Swift.Error {
        case couldNotOpenBankApp
        case timedOut
    }

    // MARK: Dependencies

    weak var delegate: TinkoffPayControllerDelegate?

    private let paymentService: IAcquiringPaymentsService
    private let tinkoffPayService: IAcquiringTinkoffPayService
    private let applicationOpener: IUIApplication
    private let paymentStatusService: IPaymentStatusService
    private let repeatedRequestHelper: IRepeatedRequestHelper

    private let paymentStatusRetriesCount: Int
    private let successfulStatuses: Set<AcquiringStatus>
    private let unsuccessfulStatuses: Set<AcquiringStatus>

    // MARK: Init

    init(
        paymentService: IAcquiringPaymentsService,
        tinkoffPayService: IAcquiringTinkoffPayService,
        applicationOpener: IUIApplication,
        paymentStatusService: IPaymentStatusService,
        repeatedRequestHelper: IRepeatedRequestHelper,
        paymentStatusRetriesCount: Int,
        successfulStatuses: Set<AcquiringStatus> = [.authorized, .confirmed],
        unsuccessfulStatuses: Set<AcquiringStatus> = [.rejected]

    ) {
        self.paymentService = paymentService
        self.tinkoffPayService = tinkoffPayService
        self.applicationOpener = applicationOpener
        self.paymentStatusService = paymentStatusService
        self.repeatedRequestHelper = repeatedRequestHelper
        self.paymentStatusRetriesCount = paymentStatusRetriesCount
        self.successfulStatuses = successfulStatuses
        self.unsuccessfulStatuses = unsuccessfulStatuses
    }

    // MARK: ITinkoffPayController

    func performPayment(paymentFlow: PaymentFlow, method: TinkoffPayMethod) {
        switch paymentFlow {
        case let .full(paymentOptions):
            performInitPayment(paymentOptions: paymentOptions, method: method)
        case let .finish(paymentId, _):
            getTinkoffPayLink(paymentId: paymentId, method: method)
        }
    }

    // MARK: Business Logic

    private func performInitPayment(paymentOptions: PaymentOptions, method: TinkoffPayMethod) {
        paymentService.initPayment(data: .data(with: paymentOptions)) { [weak self] result in
            guard let self = self else { return }

            switch result {
            case let .success(payload):
                self.getTinkoffPayLink(paymentId: payload.paymentId, method: method)
            case let .failure(error):
                self.completeWithError(error)
            }
        }
    }

    private func getTinkoffPayLink(paymentId: String, method: TinkoffPayMethod) {
        let data = GetTinkoffLinkData(paymentId: paymentId, version: method.version)

        tinkoffPayService.getTinkoffPayLink(data: data) { [weak self] result in
            guard let self = self else { return }

            switch result {
            case let .success(payload):
                self.openApplication(with: payload.redirectUrl, paymentId: paymentId)
            case let .failure(error):
                self.completeWithError(error)
            }
        }
    }

    private func openApplication(with url: URL, paymentId: String) {
        DispatchQueue.performOnMain { [weak self] in
            guard let self = self else { return }

            self.applicationOpener.open(url) { isOpened in
                if isOpened {
                    self.delegate?.tinkoffPayController(self, didOpenBankAppWith: url)
                    self.requestPaymentState(paymentId: paymentId)
                } else {
                    self.delegate?.tinkoffPayController(self, completedDueToInabilityToOpenBankApp: Error.couldNotOpenBankApp)
                }
            }
        }
    }

    private func requestPaymentState(paymentId: String, requestAttempt: Int = .zero) {
        let requestAttempt = requestAttempt + 1
        let retryingAllowed = requestAttempt <= paymentStatusRetriesCount

        repeatedRequestHelper.executeWithWaitingIfNeeded { [weak self] in
            guard let self = self else { return }

            self.paymentStatusService.getPaymentState(paymentId: paymentId) { result in
                switch result {
                case let .success(paymentState) where self.successfulStatuses.contains(paymentState.status):
                    self.completeWithSuccessful(paymentState: paymentState)
                case let .success(paymentState) where self.unsuccessfulStatuses.contains(paymentState.status):
                    self.completeWithUnsuccessful(paymentState: paymentState)
                case let .success(paymentState) where retryingAllowed:
                    self.receiveIntermediate(paymentState: paymentState)
                    self.requestPaymentState(paymentId: paymentId, requestAttempt: requestAttempt)
                case .success:
                    self.completeWithError(Error.timedOut)
                case .failure where retryingAllowed:
                    self.requestPaymentState(paymentId: paymentId, requestAttempt: requestAttempt)
                case let .failure(error):
                    self.completeWithError(error)
                }
            }
        }
    }

    // MARK: Event Handlers

    private func receiveIntermediate(paymentState: GetPaymentStatePayload) {
        DispatchQueue.performOnMain { [weak self] in
            guard let self = self else { return }

            self.delegate?.tinkoffPayController(self, didReceiveIntermediate: paymentState)
        }
    }

    private func completeWithSuccessful(paymentState: GetPaymentStatePayload) {
        DispatchQueue.performOnMain { [weak self] in
            guard let self = self else { return }

            self.delegate?.tinkoffPayController(self, completedWithSuccessful: paymentState)
        }
    }

    private func completeWithUnsuccessful(paymentState: GetPaymentStatePayload) {
        DispatchQueue.performOnMain { [weak self] in
            guard let self = self else { return }

            self.delegate?.tinkoffPayController(self, completedWithFailed: paymentState, error: Error.couldNotOpenBankApp)
        }
    }

    private func completeWithError(_ error: Swift.Error) {
        DispatchQueue.performOnMain { [weak self] in
            guard let self = self else { return }

            self.delegate?.tinkoffPayController(self, completedWith: error)
        }
    }
}
