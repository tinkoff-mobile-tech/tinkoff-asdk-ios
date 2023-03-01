//
//  MainFormPaymentMethod.swift
//  TinkoffASDKUI
//
//  Created by r.akhmadeev on 01.02.2023.
//

import Foundation

enum MainFormPaymentMethod: Comparable, Hashable {
    case tinkoffPay(version: String)
    case card
    case sbp
}
