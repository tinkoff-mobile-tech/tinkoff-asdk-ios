//
//  MainFormRouterMock.swift
//  TinkoffASDKUI-Unit-Tests
//
//  Created by Aleksandr Pravosudov on 13.06.2023.
//

import TinkoffASDKCore
@testable import TinkoffASDKUI

final class MainFormRouterMock: IMainFormRouter {

    // MARK: - openCardPaymentList

    typealias OpenCardPaymentListArguments = (paymentFlow: PaymentFlow, cards: [PaymentCard], selectedCard: PaymentCard, cardListOutput: ICardListPresenterOutput?, cardPaymentOutput: ICardPaymentPresenterModuleOutput?, cardScannerDelegate: ICardScannerDelegate?)

    var openCardPaymentListCallsCount = 0
    var openCardPaymentListReceivedArguments: OpenCardPaymentListArguments?
    var openCardPaymentListReceivedInvocations: [OpenCardPaymentListArguments] = []

    func openCardPaymentList(paymentFlow: PaymentFlow, cards: [PaymentCard], selectedCard: PaymentCard, cardListOutput: ICardListPresenterOutput?, cardPaymentOutput: ICardPaymentPresenterModuleOutput?, cardScannerDelegate: ICardScannerDelegate?) {
        openCardPaymentListCallsCount += 1
        let arguments = (paymentFlow, cards, selectedCard, cardListOutput, cardPaymentOutput, cardScannerDelegate)
        openCardPaymentListReceivedArguments = arguments
        openCardPaymentListReceivedInvocations.append(arguments)
    }

    // MARK: - openCardPayment

    typealias OpenCardPaymentArguments = (paymentFlow: PaymentFlow, cards: [PaymentCard]?, output: ICardPaymentPresenterModuleOutput?, cardListOutput: ICardListPresenterOutput?, cardScannerDelegate: ICardScannerDelegate?)

    var openCardPaymentCallsCount = 0
    var openCardPaymentReceivedArguments: OpenCardPaymentArguments?
    var openCardPaymentReceivedInvocations: [OpenCardPaymentArguments] = []

    func openCardPayment(paymentFlow: PaymentFlow, cards: [PaymentCard]?, output: ICardPaymentPresenterModuleOutput?, cardListOutput: ICardListPresenterOutput?, cardScannerDelegate: ICardScannerDelegate?) {
        openCardPaymentCallsCount += 1
        let arguments = (paymentFlow, cards, output, cardListOutput, cardScannerDelegate)
        openCardPaymentReceivedArguments = arguments
        openCardPaymentReceivedInvocations.append(arguments)
    }

    // MARK: - openSBP

    typealias OpenSBPArguments = (paymentFlow: PaymentFlow, banks: [SBPBank]?, output: ISBPBanksModuleOutput?, paymentSheetOutput: ISBPPaymentSheetPresenterOutput?)

    var openSBPCallsCount = 0
    var openSBPReceivedArguments: OpenSBPArguments?
    var openSBPReceivedInvocations: [OpenSBPArguments] = []

    func openSBP(paymentFlow: PaymentFlow, banks: [SBPBank]?, output: ISBPBanksModuleOutput?, paymentSheetOutput: ISBPPaymentSheetPresenterOutput?) {
        openSBPCallsCount += 1
        let arguments = (paymentFlow, banks, output, paymentSheetOutput)
        openSBPReceivedArguments = arguments
        openSBPReceivedInvocations.append(arguments)
    }

    // MARK: - openTinkoffPayLanding

    var openTinkoffPayLandingCallsCount = 0
    var openTinkoffPayLandingCompletionShouldExecute = false

    func openTinkoffPayLanding(completion: VoidBlock?) {
        openTinkoffPayLandingCallsCount += 1
        if openTinkoffPayLandingCompletionShouldExecute {
            completion?()
        }
    }
}
