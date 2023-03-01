//
//  IMainFormDataStateLoader.swift
//  TinkoffASDKUI
//
//  Created by r.akhmadeev on 26.02.2023.
//

import Foundation

protocol IMainFormDataStateLoader {
    func loadState(
        for paymentFlow: PaymentFlow,
        completion: @escaping (Result<MainFormDataState, Error>) -> Void
    )
}
