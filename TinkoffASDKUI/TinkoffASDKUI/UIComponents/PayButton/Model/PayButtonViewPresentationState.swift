//
//  PayButtonViewPresentationState.swift
//  TinkoffASDKUI
//
//  Created by r.akhmadeev on 08.02.2023.
//

import Foundation

enum PayButtonViewPresentationState: Equatable {
    case pay
    case payWithAmount(amount: Int)
    case tinkoffPay
    case sbp
}
