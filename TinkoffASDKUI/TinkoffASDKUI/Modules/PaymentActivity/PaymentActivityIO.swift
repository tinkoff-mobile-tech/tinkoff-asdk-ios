//
//  PaymentActivityIO.swift
//  TinkoffASDKUI
//
//  Created by r.akhmadeev on 12.12.2022.
//

import Foundation

protocol IPaymentActivityViewInput: AnyObject {
    func update(with state: PaymentActivityViewState, animated: Bool)
    func close()
}

protocol IPaymentActivityViewOutput {
    func viewDidLoad()
    func primaryButtonTapped()
    func viewWasClosed()
}
