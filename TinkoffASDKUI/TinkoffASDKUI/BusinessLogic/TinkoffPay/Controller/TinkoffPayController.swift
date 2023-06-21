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

    private final class Process: Cancellable {
        var isActive: Bool { !isCancelled.wrappedValue }
        private let isCancelled = Atomic(wrappedValue: false)

        func cancel() {
            isCancelled.store(newValue: true)
        }
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
    private let mainDispatchQueue: IDispatchQueue

    // MARK: Init

    init(
        paymentService: IAcquiringPaymentsService,
        tinkoffPayService: IAcquiringTinkoffPayService,
        applicationOpener: IUIApplication,
        paymentStatusService: IPaymentStatusService,
        repeatedRequestHelper: IRepeatedRequestHelper,
        paymentStatusRetriesCount: Int,
        successfulStatuses: Set<AcquiringStatus> = [.authorized, .confirmed],
        unsuccessfulStatuses: Set<AcquiringStatus> = [.rejected],
        mainDispatchQueue: IDispatchQueue = DispatchQueue.main
    ) {
        self.paymentService = paymentService
        self.tinkoffPayService = tinkoffPayService
        self.applicationOpener = applicationOpener
        self.paymentStatusService = paymentStatusService
        self.repeatedRequestHelper = repeatedRequestHelper
        self.paymentStatusRetriesCount = paymentStatusRetriesCount
        self.successfulStatuses = successfulStatuses
        self.unsuccessfulStatuses = unsuccessfulStatuses
        self.mainDispatchQueue = mainDispatchQueue
    }

    // MARK: ITinkoffPayController

    @discardableResult
    func performPayment(paymentFlow: PaymentFlow, method: TinkoffPayMethod) -> Cancellable {
        let process = Process()

        let paymentFlow = paymentFlow.mergePaymentDataIfNeeded(.tinkoffPayData)

        switch paymentFlow {
        case let .full(paymentOptions):
            performInitPayment(paymentOptions: paymentOptions, method: method, process: process)
        case let .finish(paymentOptions):
            getTinkoffPayLink(paymentId: paymentOptions.paymentId, method: method, process: process)
        }

        return process
    }

    // MARK: Business Logic

    private func performInitPayment(paymentOptions: PaymentOptions, method: TinkoffPayMethod, process: Process) {
        paymentService.initPayment(data: .data(with: paymentOptions)) { [weak self] result in
            guard let self = self, process.isActive else { return }

            switch result {
            case let .success(payload):
                self.getTinkoffPayLink(paymentId: payload.paymentId, method: method, process: process)
            case let .failure(error):
                DispatchQueue.performOnMain {
                    guard process.isActive else { return }
                    self.delegate?.tinkoffPayController(self, completedWith: error)
                }
            }
        }
    }

    private func getTinkoffPayLink(paymentId: String, method: TinkoffPayMethod, process: Process) {
        let data = GetTinkoffLinkData(paymentId: paymentId, version: method.version)

        tinkoffPayService.getTinkoffPayLink(data: data) { [weak self] result in
            guard let self = self else { return }

            DispatchQueue.performOnMain {
                guard process.isActive else { return }

                switch result {
                case let .success(payload):
                    self.openApplication(with: payload.redirectUrl, paymentId: paymentId, process: process)
                case let .failure(error):
                    self.delegate?.tinkoffPayController(self, completedWith: error)
                }
            }
        }
    }

    private func openApplication(with url: URL, paymentId: String, process: Process) {
        applicationOpener.open(url) { [weak self] isOpened in
            guard let self = self, process.isActive else { return }

            if isOpened {
                self.delegate?.tinkoffPayController(self, didOpenTinkoffPay: url)
                self.requestPaymentState(paymentId: paymentId, process: process)
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
        process: Process,
        requestAttempt: Int = .zero,
        lastReceivedPaymentState: GetPaymentStatePayload? = nil
    ) {
        let requestAttempt = requestAttempt + 1
        let retryingAllowed = requestAttempt < paymentStatusRetriesCount

        repeatedRequestHelper.executeWithWaitingIfNeeded { [weak self] in
            guard let self = self, process.isActive else { return }

            self.paymentStatusService.getPaymentState(paymentId: paymentId, receiveOn: self.mainDispatchQueue) { result in
                guard process.isActive else { return }

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
                        process: process,
                        requestAttempt: requestAttempt,
                        lastReceivedPaymentState: paymentState
                    )
                case let .success(paymentState):
                    self.delegate?.tinkoffPayController(
                        self,
                        completedWithTimeout: paymentState,
                        error: Error.didNotWaitForSuccessfulPaymentState(lastReceivedPaymentState: paymentState)
                    )
                case .failure where retryingAllowed:
                    self.requestPaymentState(
                        paymentId: paymentId,
                        process: process,
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
        receiveOn queue: IDispatchQueue,
        completion: @escaping (Result<GetPaymentStatePayload, Error>) -> Void
    ) {
        getPaymentState(paymentId: paymentId) { result in
            queue.async { completion(result) }
        }
    }
}
