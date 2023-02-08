//
//  MainFormCellType.swift
//  TinkoffASDKUI
//
//  Created by r.akhmadeev on 24.01.2023.
//

import Foundation

enum MainFormCellType {
    case orderDetails
    case savedCard(ISavedCardViewOutput)
    case payButton
    case otherPaymentMethodsHeader
    case otherPaymentMethod(MainFormPaymentMethod)
}
