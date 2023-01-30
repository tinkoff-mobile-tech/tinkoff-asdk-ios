//
//  CardPaymentCellType.swift
//  TinkoffASDKUI
//
//  Created by Aleksandr Pravosudov on 27.01.2023.
//

enum CardPaymentCellType: Equatable {
    case savedCard(ISavedCardViewOutput?)
    case cardField
    case getReceipt(ISwitchViewOutput)
    case emailField(IEmailViewOutput)
    case payButton

    static func == (lhs: CardPaymentCellType, rhs: CardPaymentCellType) -> Bool {
        switch (lhs, rhs) {
        case (.savedCard, .savedCard),
             (.cardField, .cardField),
             (.getReceipt, .getReceipt),
             (.emailField, .emailField),
             (.payButton, .payButton):
            return true
        default: return false
        }
    }
}
