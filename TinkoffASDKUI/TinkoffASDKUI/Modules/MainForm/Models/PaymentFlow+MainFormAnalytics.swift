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

        return mergePaymentDataIfNeeded(initData: [.primaryMethodKey: methodName])
    }

    func withSavedCardAnalytics() -> PaymentFlow {
        mergePaymentDataIfNeeded(initData: [.chosenMethodKey: String.savedCard])
    }

    func withNewCardAnalytics() -> PaymentFlow {
        mergePaymentDataIfNeeded(initData: [.chosenMethodKey: String.newCard])
    }

    func withTinkoffPayAnalytics() -> PaymentFlow {
        mergePaymentDataIfNeeded(initData: [.chosenMethodKey: String.tinkoffPay])
    }

    func withSBPAnalytics() -> PaymentFlow {
        mergePaymentDataIfNeeded(initData: [.chosenMethodKey: String.sbp])
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
