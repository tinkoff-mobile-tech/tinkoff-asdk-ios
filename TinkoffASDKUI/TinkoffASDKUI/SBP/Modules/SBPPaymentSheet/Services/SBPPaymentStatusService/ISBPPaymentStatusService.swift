//
//  ISBPPaymentStatusService.swift
//  TinkoffASDKUI
//
//  Created by Aleksandr Pravosudov on 17.01.2023.
//

import TinkoffASDKCore

typealias SBPPaymentStatusServiceCompletion = (Result<PaymentStatus, Error>) -> Void

protocol ISBPPaymentStatusService {
    func getPaymentStatus(paymentId: String, completion: @escaping SBPPaymentStatusServiceCompletion)
}
