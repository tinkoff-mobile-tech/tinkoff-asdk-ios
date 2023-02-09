//
//  IPaymentStatusService.swift
//  TinkoffASDKUI
//
//  Created by Aleksandr Pravosudov on 17.01.2023.
//

import TinkoffASDKCore

typealias PaymentStatusServiceCompletion = (Result<GetPaymentStatePayload, Error>) -> Void

protocol IPaymentStatusService {
    func getPaymentState(paymentId: String, completion: @escaping PaymentStatusServiceCompletion)
}
