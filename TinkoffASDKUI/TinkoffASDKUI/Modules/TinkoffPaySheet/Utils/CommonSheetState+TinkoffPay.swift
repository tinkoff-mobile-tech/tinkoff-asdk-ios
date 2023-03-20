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
            title: Loc.CommonSheet.TinkoffPay.Waiting.title,
            secondaryButtonTitle: Loc.CommonSheet.TinkoffPay.Waiting.secondaryButton
        )
    }

    static var paid: CommonSheetState {
        CommonSheetState(
            status: .succeeded,
            title: Loc.CommonSheet.TinkoffPay.Paid.title,
            primaryButtonTitle: Loc.CommonSheet.TinkoffPay.Paid.primaryButton
        )
    }

    static var timedOutOnIndependentFlow: CommonSheetState {
        CommonSheetState(
            status: .failed,
            title: Loc.CommonSheet.TinkoffPay.TimedOut.title,
            primaryButtonTitle: Loc.CommonSheet.TinkoffPay.TimedOut.primaryButton
        )
    }

    static var timedOutOnMainFormFlow: CommonSheetState {
        CommonSheetState(
            status: .failed,
            title: Loc.CommonSheet.TinkoffPay.TimedOut.title,
            primaryButtonTitle: Loc.CommonSheet.PaymentForm.TinkoffPay.TimedOut.primaryButton
        )
    }

    static var failedPaymentOnIndependentFlow: CommonSheetState {
        CommonSheetState(
            status: .failed,
            title: Loc.CommonSheet.TinkoffPay.FailedPayment.title,
            primaryButtonTitle: Loc.CommonSheet.TinkoffPay.FailedPayment.primaryButton
        )
    }

    static var failedPaymentOnMainFormFlow: CommonSheetState {
        CommonSheetState(
            status: .failed,
            title: Loc.CommonSheet.TinkoffPay.FailedPayment.title,
            primaryButtonTitle: Loc.CommonSheet.PaymentForm.TinkoffPay.FailedPayment.primaryButton
        )
    }
}
