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
        case tinkoffPayAppIsNotInstalled
    }

    // MARK: Dependencies

    weak var delegate: TinkoffPayControllerDelegate?
    private let paymentService: IAcquiringPaymentsService
    private let tinkoffPayService: IAcquiringTinkoffPayService
    private let applicationOpener: IUIApplication
    private let paymentStatusService: IPaymentStatusService

    // MARK: Init

    init(
        paymentService: IAcquiringPaymentsService,
        tinkoffPayService: IAcquiringTinkoffPayService,
        applicationOpener: IUIApplication,
        paymentStatusService: IPaymentStatusService
    ) {
        self.paymentService = paymentService
        self.tinkoffPayService = tinkoffPayService
        self.applicationOpener = applicationOpener
        self.paymentStatusService = paymentStatusService
    }

    // MARK: ITinkoffPayController

    func performPayment(paymentFlow: PaymentFlow, version: String) {
        switch paymentFlow {
        case let .full(paymentOptions):
            performInitPayment(paymentOptions: paymentOptions, version: version)
        case let .finish(paymentId, _):
            getTinkoffPayLink(paymentId: paymentId, version: version)
        }
    }

    // MARK: Helpers

    private func performInitPayment(paymentOptions: PaymentOptions, version: String) {
        paymentService.initPayment(data: .data(with: paymentOptions)) { [weak self] result in
            guard let self = self else { return }

            switch result {
            case let .success(payload):
                self.getTinkoffPayLink(paymentId: payload.paymentId, version: version)
            case let .failure(error):
                DispatchQueue.performOnMain {
                    self.delegate?.tinkoffPayController(self, failedWith: error)
                }
            }
        }
    }

    private func getTinkoffPayLink(paymentId: String, version: String) {
        let data = GetTinkoffLinkData(paymentId: paymentId, version: version)

        tinkoffPayService.getTinkoffPayLink(data: data) { [weak self] result in
            guard let self = self else { return }

            DispatchQueue.performOnMain {
                switch result {
                case let .success(payload):
                    self.openApplication(with: payload.redirectUrl, paymentId: paymentId)
                case let .failure(error):
                    self.delegate?.tinkoffPayController(self, failedWith: error)
                }
            }
        }
    }

    private func openApplication(with url: URL, paymentId: String) {
        applicationOpener.open(url, options: [:]) { [weak self] isOpened in
            guard let self = self else { return }

            if isOpened {
                self.delegate?.tinkoffPayControllerOpenedBankApp(self)
                self.startGetStatePolling(paymentId: paymentId)
            } else {
                self.delegate?.tinkoffPayController(self, failedToOpenBankAppWith: Error.tinkoffPayAppIsNotInstalled)
            }
        }
    }

    private func startGetStatePolling(paymentId: String) {}
}
