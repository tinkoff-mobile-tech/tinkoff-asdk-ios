//
//  SBPPaymentStatusService.swift
//  TinkoffASDKUI
//
//  Created by Aleksandr Pravosudov on 17.01.2023.
//

import TinkoffASDKCore

final class SBPPaymentStatusService: ISBPPaymentStatusService {

    // MARK: Dependencies

    private let acquiringSdk: AcquiringSdk

    // MARK: Initialization

    init(acquiringSdk: AcquiringSdk) {
        self.acquiringSdk = acquiringSdk
    }

    // MARK: ISBPPaymentStatusService

    /// Запрос на получение статуса платежа
    /// - Parameters:
    ///   - paymentId: платежный идентификатор
    ///   - completion: в случае success выдает статус платежа
    func getPaymentStatus(paymentId: String, completion: @escaping SBPPaymentStatusServiceCompletion) {
        let stateData = GetPaymentStateData(paymentId: paymentId)
        acquiringSdk.getPaymentState(data: stateData, completion: completion)
    }
}
