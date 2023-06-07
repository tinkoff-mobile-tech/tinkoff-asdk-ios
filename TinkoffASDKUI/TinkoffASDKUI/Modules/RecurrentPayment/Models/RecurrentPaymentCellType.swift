//
//  RecurrentPaymentCellType.swift
//  TinkoffASDKUI
//
//  Created by Aleksandr Pravosudov on 03.03.2023.
//

enum RecurrentPaymentCellType: Equatable {
    case savedCard(ISavedCardViewOutput)
    case payButton(IPayButtonViewOutput)

    static func == (lhs: RecurrentPaymentCellType, rhs: RecurrentPaymentCellType) -> Bool {
        switch (lhs, rhs) {
        case (.savedCard, .savedCard),
             (.payButton, .payButton):
            return true
        default: return false
        }
    }
}
