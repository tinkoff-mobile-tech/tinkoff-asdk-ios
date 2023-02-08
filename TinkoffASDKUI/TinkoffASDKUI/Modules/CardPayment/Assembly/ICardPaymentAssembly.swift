//
//  ICardPaymentAssembly.swift
//  TinkoffASDKUI
//
//  Created by Aleksandr Pravosudov on 20.01.2023.
//

import TinkoffASDKCore
import UIKit

protocol ICardPaymentAssembly {
    func build(
        activeCards: [PaymentCard],
        paymentFlow: PaymentFlow,
        amount: Int64,
        output: ICardPaymentPresenterModuleOutput?
    ) -> UIViewController
}
