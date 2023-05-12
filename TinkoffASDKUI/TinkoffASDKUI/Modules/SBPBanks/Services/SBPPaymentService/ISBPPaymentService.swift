//
//  ISBPPaymentService.swift
//  TinkoffASDKUI
//
//  Created by Aleksandr Pravosudov on 16.01.2023.
//

import TinkoffASDKCore

typealias SBPPaymentServiceCompletion = (Result<GetQRPayload, Error>) -> Void

protocol ISBPPaymentService {
    func loadPaymentQr(completion: @escaping SBPPaymentServiceCompletion)
}
