//
//  PaymentStatusService.swift
//  TinkoffASDKUI
//
//  Created by Aleksandr Pravosudov on 17.01.2023.
//

import TinkoffASDKCore

final class PaymentStatusService: IPaymentStatusService {

    // MARK: Dependencies

    private let paymentService: IAcquiringPaymentsService

    // MARK: Initialization

    init(paymentService: IAcquiringPaymentsService) {
        self.paymentService = paymentService
    }

    // MARK: IPaymentStatusService

    /// Запрос на получение статуса платежа
    /// - Parameters:
    ///   - paymentId: платежный идентификатор
    ///   - completion: в случае success выдает статус платежа
    func getPaymentState(paymentId: String, completion: @escaping PaymentStatusServiceCompletion) {
        let stateData = GetPaymentStateData(paymentId: paymentId)
        paymentService.getPaymentState(data: stateData, completion: completion)
    }
}
