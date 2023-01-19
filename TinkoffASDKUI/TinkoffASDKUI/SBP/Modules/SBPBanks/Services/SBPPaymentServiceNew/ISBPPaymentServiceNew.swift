//
//  ISBPPaymentServiceNew.swift
//  TinkoffASDKUI
//
//  Created by Aleksandr Pravosudov on 16.01.2023.
//

import TinkoffASDKCore

typealias SBPPaymentServiceNewCompletion = (Result<GetQRPayload, Error>) -> Void

protocol ISBPPaymentServiceNew {
    func loadPaymentQr(completion: @escaping SBPPaymentServiceNewCompletion)
}
