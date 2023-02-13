//
//  PaymentStatusService.swift
//  TinkoffASDKUI
//
//  Created by Aleksandr Pravosudov on 17.01.2023.
//

import TinkoffASDKCore

final class PaymentStatusService: IPaymentStatusService {

    // MARK: Dependencies

    private let acquiringSdk: AcquiringSdk

    // MARK: Initialization

    init(acquiringSdk: AcquiringSdk) {
        self.acquiringSdk = acquiringSdk
    }

    // MARK: IPaymentStatusService

    /// Запрос на получение статуса платежа
    /// - Parameters:
    ///   - paymentId: платежный идентификатор
    ///   - completion: в случае success выдает статус платежа
    func getPaymentState(paymentId: String, completion: @escaping PaymentStatusServiceCompletion) {
        let stateData = GetPaymentStateData(paymentId: paymentId)
        acquiringSdk.getPaymentState(data: stateData, completion: completion)
    }
}
