//
//  SBPPaymentServiceNew.swift
//  TinkoffASDKUI
//
//  Created by Aleksandr Pravosudov on 16.01.2023.
//

import TinkoffASDKCore

final class SBPPaymentServiceNew: ISBPPaymentServiceNew {

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

// MARK: - ISBPPaymentServiceNew

extension SBPPaymentServiceNew {
    func loadPaymentQr(completion: @escaping SBPPaymentServiceNewCompletion) {
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
        case let .finish(paymentId, _):
            getPaymentQrData(paymentId: String(paymentId), completion: completion)
        }
    }
}

// MARK: - Private

extension SBPPaymentServiceNew {
    private func getPaymentQrData(paymentId: String, completion: @escaping SBPPaymentServiceNewCompletion) {
        let qrData = GetQRData(paymentId: paymentId, paymentInvoiceType: .url)
        acquiringSdk.getQR(data: qrData, completion: completion)
    }
}
