//
//  CommonSheetState+TinkoffPay.swift
//  TinkoffASDKUI
//
//  Created by r.akhmadeev on 15.03.2023.
//

import Foundation

extension CommonSheetState {
    /// Область видимости для состояний `Tinkoff Pay`
    enum TinkoffPay {}

    /// Область видимости для состояний `Tinkoff Pay`
    static var tinkoffPay: TinkoffPay.Type { TinkoffPay.self }
}

extension CommonSheetState.TinkoffPay {
    static var processing: CommonSheetState {
        CommonSheetState(
            status: .processing,
            title: "Ожидаем оплату в приложении банка",
            secondaryButtonTitle: "Отмена"
        )
    }

    static var paid: CommonSheetState {
        CommonSheetState(
            status: .succeeded,
            title: "Оплачено",
            primaryButtonTitle: "Понятно"
        )
    }

    static var timedOut: CommonSheetState {
        CommonSheetState(
            status: .failed,
            title: "Время оплаты истекло",
            primaryButtonTitle: "Понятно"
        )
    }

    static var failedPaymentOnIndependentFlow: CommonSheetState {
        CommonSheetState(
            status: .failed,
            title: "Не получилось оплатить",
            primaryButtonTitle: "Понятно"
        )
    }

    static var failedPaymentOnMainFormFlow: CommonSheetState {
        CommonSheetState(
            status: .failed,
            title: "Не получилось оплатить",
            primaryButtonTitle: "Выбрать другой способ оплаты"
        )
    }
}
