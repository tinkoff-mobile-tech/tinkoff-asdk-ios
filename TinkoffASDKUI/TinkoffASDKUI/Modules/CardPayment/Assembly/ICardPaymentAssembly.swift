//
//  ICardPaymentAssembly.swift
//  TinkoffASDKUI
//
//  Created by Aleksandr Pravosudov on 20.01.2023.
//

import TinkoffASDKCore
import UIKit

protocol ICardPaymentAssembly {
    func build(activeCards: [PaymentCard], customerEmail: String) -> UIViewController
}
