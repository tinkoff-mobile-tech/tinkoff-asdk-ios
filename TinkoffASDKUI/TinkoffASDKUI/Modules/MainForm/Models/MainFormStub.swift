//
//  MainFormStub.swift
//  TinkoffASDKUI
//
//  Created by r.akhmadeev on 19.01.2023.
//

import Foundation

// TODO: MIC-7708 Удалить заглушку состояний
/// Временная заглушка состояний экрана для отладки и тестирования главной формы оплаты через Sample
public struct MainFormStub {
    public enum PayMethod: CaseIterable {
        case card
        case sbp
        case tinkoffPay
    }

    /// главный метод оплаты (в блоке с суммой оплаты)
    public let primaryPayMethod: PayMethod

    public init(primaryPayMethod: PayMethod) {
        self.primaryPayMethod = primaryPayMethod
    }
}

extension MainFormStub.PayMethod {
    var domainModel: MainFormPaymentMethod {
        switch self {
        case .card:
            return .card
        case .sbp:
            return .sbp
        case .tinkoffPay:
            return .tinkoffPay(version: "")
        }
    }
}
