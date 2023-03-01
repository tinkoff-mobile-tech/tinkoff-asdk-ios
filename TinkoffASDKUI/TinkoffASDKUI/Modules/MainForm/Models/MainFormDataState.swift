//
//  MainFormDataState.swift
//  TinkoffASDKUI
//
//  Created by r.akhmadeev on 26.02.2023.
//

import Foundation
import TinkoffASDKCore

/// Состояние данных главной платежной формы
struct MainFormDataState {
    /// Приоритетный метод оплаты, отображаемый в верхней части формы
    let primaryPaymentMethod: MainFormPaymentMethod
    /// Альтернативные способы оплаты, отображаемые в нижней части формы
    let otherPaymentMethods: [MainFormPaymentMethod]
    /// Карты, которые получили на этапе определения методов оплаты или после открытия оплаты по карте
    /// Также список будет изменяться при удалении карты пользователем
    var cards: [PaymentCard]?
    /// Список банков СБП, которые получили на этапе определения методов оплаты или после открытия оплаты по СБП
    var sbpBanks: [SBPBank]?
}

extension MainFormDataState {
    static var initial: MainFormDataState {
        MainFormDataState(
            primaryPaymentMethod: .card,
            otherPaymentMethods: [],
            cards: nil,
            sbpBanks: nil
        )
    }

    var hasCards: Bool {
        cards?.isEmpty == false
    }
}
