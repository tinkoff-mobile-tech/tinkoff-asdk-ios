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
        case couldNotOpenTinkoffPayApp(url: URL)
        case didNotWaitForSuccessfulPaymentState(lastReceivedPaymentState: GetPaymentStatePayload?, underlyingError: Swift.Error? = nil)
        case didReceiveFailedPaymentState(GetPaymentStatePayload)
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
        let paymentFlow = paymentFlow.mergePaymentDataIfNeeded(.tinkoffPayData)

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
                DispatchQueue.performOnMain {
                    self.delegate?.tinkoffPayController(self, completedWith: error)
                }
            }
        }
    }

    private func getTinkoffPayLink(paymentId: String, method: TinkoffPayMethod) {
        let data = GetTinkoffLinkData(paymentId: paymentId, version: method.version)

        tinkoffPayService.getTinkoffPayLink(data: data) { [weak self] result in
            guard let self = self else { return }

            DispatchQueue.performOnMain {
                switch result {
                case let .success(payload):
                    self.openApplication(with: payload.redirectUrl, paymentId: paymentId)
                case let .failure(error):
                    self.delegate?.tinkoffPayController(self, completedWith: error)
                }
            }
        }
    }

    private func openApplication(with url: URL, paymentId: String) {
        applicationOpener.open(url) { [weak self] isOpened in
            guard let self = self else { return }

            if isOpened {
                self.delegate?.tinkoffPayController(self, didOpenTinkoffPay: url)
                self.requestPaymentState(paymentId: paymentId)
            } else {
                self.delegate?.tinkoffPayController(
                    self,
                    completedDueToInabilityToOpenTinkoffPay: url,
                    error: Error.couldNotOpenTinkoffPayApp(url: url)
                )
            }
        }
    }

    private func requestPaymentState(
        paymentId: String,
        requestAttempt: Int = .zero,
        lastReceivedPaymentState: GetPaymentStatePayload? = nil
    ) {
        let requestAttempt = requestAttempt + 1
        let retryingAllowed = requestAttempt < paymentStatusRetriesCount

        repeatedRequestHelper.executeWithWaitingIfNeeded { [weak self] in
            guard let self = self else { return }

            self.paymentStatusService.getPaymentState(paymentId: paymentId, receiveOn: .main) { result in
                switch result {
                case let .success(paymentState) where self.successfulStatuses.contains(paymentState.status):
                    self.delegate?.tinkoffPayController(self, completedWithSuccessful: paymentState)
                case let .success(paymentState) where self.unsuccessfulStatuses.contains(paymentState.status):
                    self.delegate?.tinkoffPayController(
                        self,
                        completedWithFailed: paymentState,
                        error: Error.didReceiveFailedPaymentState(paymentState)
                    )
                case let .success(paymentState) where retryingAllowed:
                    self.delegate?.tinkoffPayController(self, didReceiveIntermediate: paymentState)
                    self.requestPaymentState(
                        paymentId: paymentId,
                        requestAttempt: requestAttempt,
                        lastReceivedPaymentState: paymentState
                    )
                case .success:
                    self.delegate?.tinkoffPayController(
                        self,
                        completedWith: Error.didNotWaitForSuccessfulPaymentState(lastReceivedPaymentState: lastReceivedPaymentState)
                    )
                case .failure where retryingAllowed:
                    self.requestPaymentState(
                        paymentId: paymentId,
                        requestAttempt: requestAttempt,
                        lastReceivedPaymentState: lastReceivedPaymentState
                    )
                case let .failure(error):
                    self.delegate?.tinkoffPayController(
                        self,
                        completedWith: Error.didNotWaitForSuccessfulPaymentState(
                            lastReceivedPaymentState: lastReceivedPaymentState,
                            underlyingError: error
                        )
                    )
                }
            }
        }
    }
}

// MARK: - Constants

private extension Dictionary where Key == String, Value == String {
    static var tinkoffPayData: [String: String] {
        ["TinkoffPayWeb": "true"]
    }
}

// MARK: - TinkoffPayController.Error + LocalizedError

extension TinkoffPayController.Error: LocalizedError {
    var errorDescription: String? {
        switch self {
        case let .couldNotOpenTinkoffPayApp(url):
            return "Could not open TinkoffPay App with url \(url)"
        case let .didReceiveFailedPaymentState(paymentState):
            return "Something went wrong in the payment process: the payment was rejected. Payload: \(paymentState)"
        case let .didNotWaitForSuccessfulPaymentState(lastReceivedPaymentState, underlyingError):
            return "Something went wrong in the payment process: the payment did not reach final status completed"
                .appending(lastReceivedPaymentState.map { ". Last received payment payload: \($0)" } ?? "")
                .appending(underlyingError.map { ". Underlying error: \($0)" } ?? "")
        }
    }

    var recoverySuggestion: String? {
        switch self {
        case let .couldNotOpenTinkoffPayApp(url):
            return url.scheme.map { "For Tinkoff Pay to work correctly, add the scheme \($0) to the list of LSApplicationQueriesSchemes at info.plist" }
        default:
            return nil
        }
    }
}

// MARK: - IPaymentStatusService + Helpers

private extension IPaymentStatusService {
    func getPaymentState(
        paymentId: String,
        receiveOn queue: DispatchQueue,
        completion: @escaping (Result<GetPaymentStatePayload, Error>) -> Void
    ) {
        getPaymentState(paymentId: paymentId) { result in
            queue.async { completion(result) }
        }
    }
}
