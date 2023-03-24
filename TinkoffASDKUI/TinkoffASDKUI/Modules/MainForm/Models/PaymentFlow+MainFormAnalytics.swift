//
//  PaymentFlow+Analytics.swift
//  TinkoffASDKUI
//
//  Created by r.akhmadeev on 19.03.2023.
//

import Foundation

extension PaymentFlow {
    func withPrimaryMethodAnalytics(dataState: MainFormDataState) -> PaymentFlow {
        let methodName: String = {
            switch dataState.primaryPaymentMethod {
            case .tinkoffPay:
                return .tinkoffPay
            case .card where dataState.hasCards:
                return .savedCard
            case .card:
                return .newCard
            case .sbp:
                return .sbp
            }
        }()

        return mergePaymentDataIfNeeded([.primaryMethodKey: methodName])
    }

    func withSavedCardAnalytics() -> PaymentFlow {
        mergePaymentDataIfNeeded([.chosenMethodKey: .savedCard])
    }

    func withNewCardAnalytics() -> PaymentFlow {
        mergePaymentDataIfNeeded([.chosenMethodKey: .newCard])
    }

    func withTinkoffPayAnalytics() -> PaymentFlow {
        mergePaymentDataIfNeeded([.chosenMethodKey: .tinkoffPay])
    }

    func withSBPAnalytics() -> PaymentFlow {
        mergePaymentDataIfNeeded([.chosenMethodKey: .sbp])
    }
}

// MARK: - Constants

private extension String {
    static let primaryMethodKey = "main_form"
    static let chosenMethodKey = "chosen_method"
    static let savedCard = "Card"
    static let newCard = "NewCard"
    static let tinkoffPay = "TinkoffPay"
    static let sbp = "Sbp"
}
