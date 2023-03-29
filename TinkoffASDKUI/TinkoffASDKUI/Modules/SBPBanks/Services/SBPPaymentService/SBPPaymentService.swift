//
//  SBPPaymentService.swift
//  TinkoffASDKUI
//
//  Created by Aleksandr Pravosudov on 16.01.2023.
//

import TinkoffASDKCore

final class SBPPaymentService: ISBPPaymentService {

    // MARK: Dependencies

    private let acquiringSdk: AcquiringSdk
    private let paymentFlow: PaymentFlow

    // MARK: Initialization

    init(
        acquiringSdk: AcquiringSdk,
        paymentFlow: PaymentFlow
    ) {
        self.acquiringSdk = acquiringSdk
        self.paymentFlow = paymentFlow
    }
}

// MARK: - ISBPPaymentService

extension SBPPaymentService {
    func loadPaymentQr(completion: @escaping SBPPaymentServiceCompletion) {
        switch paymentFlow {
        case let .full(paymentOptions):
            acquiringSdk.initPayment(data: .data(with: paymentOptions), completion: { [weak self] result in
                switch result {
                case let .success(initPayload):
                    self?.getPaymentQrData(paymentId: initPayload.paymentId, completion: completion)
                case let .failure(error):
                    completion(.failure(error))
                }
            })
        case let .finish(paymentOptions, _):
            getPaymentQrData(paymentId: String(paymentOptions.paymentId), completion: completion)
        }
    }
}

// MARK: - Private

extension SBPPaymentService {
    private func getPaymentQrData(paymentId: String, completion: @escaping SBPPaymentServiceCompletion) {
        let qrData = GetQRData(paymentId: paymentId, paymentInvoiceType: .url)
        acquiringSdk.getQR(data: qrData, completion: completion)
    }
}
