//
//  CardPaymentRouterMock.swift
//  TinkoffASDKUI-Unit-Tests
//
//  Created by Aleksandr Pravosudov on 19.05.2023.
//

import TinkoffASDKCore
@testable import TinkoffASDKUI

final class CardPaymentRouterMock: ICardPaymentRouter {

    // MARK: - closeScreen

    typealias CloseScreenArguments = VoidBlock

    var closeScreenCallsCount = 0
    var closeScreenReceivedArguments: CloseScreenArguments?
    var closeScreenReceivedInvocations: [CloseScreenArguments?] = []
    var closeScreenCompletionShouldExecute = false

    func closeScreen(completion: VoidBlock?) {
        closeScreenCallsCount += 1
        let arguments = completion
        closeScreenReceivedArguments = arguments
        closeScreenReceivedInvocations.append(arguments)
        if closeScreenCompletionShouldExecute {
            completion?()
        }
    }

    // MARK: - showCardScanner

    typealias ShowCardScannerArguments = CardScannerCompletion

    var showCardScannerCallsCount = 0
    var showCardScannerReceivedArguments: ShowCardScannerArguments?
    var showCardScannerReceivedInvocations: [ShowCardScannerArguments?] = []
    var showCardScannerCompletionClosureInput: (cardNumber: String?, expiration: String?, cvc: String?)?

    func showCardScanner(completion: @escaping CardScannerCompletion) {
        showCardScannerCallsCount += 1
        let arguments = completion
        showCardScannerReceivedArguments = arguments
        showCardScannerReceivedInvocations.append(arguments)
        if let data = showCardScannerCompletionClosureInput {
            completion(data.0, data.1, data.2)
        }
    }

    // MARK: - openCardPaymentList

    typealias OpenCardPaymentListArguments = (paymentFlow: PaymentFlow, amount: Int64, cards: [PaymentCard], selectedCard: PaymentCard, cardListOutput: ICardListPresenterOutput?, cardPaymentOutput: ICardPaymentPresenterModuleOutput?)

    var openCardPaymentListCallsCount = 0
    var openCardPaymentListReceivedArguments: OpenCardPaymentListArguments?
    var openCardPaymentListReceivedInvocations: [OpenCardPaymentListArguments?] = []

    func openCardPaymentList(paymentFlow: PaymentFlow, amount: Int64, cards: [PaymentCard], selectedCard: PaymentCard, cardListOutput: ICardListPresenterOutput?, cardPaymentOutput: ICardPaymentPresenterModuleOutput?) {
        openCardPaymentListCallsCount += 1
        let arguments = (paymentFlow, amount, cards, selectedCard, cardListOutput, cardPaymentOutput)
        openCardPaymentListReceivedArguments = arguments
        openCardPaymentListReceivedInvocations.append(arguments)
    }
}

// MARK: - Resets

extension CardPaymentRouterMock {
    func fullReset() {
        closeScreenCallsCount = 0
        closeScreenReceivedArguments = nil
        closeScreenReceivedInvocations = []
        closeScreenCompletionShouldExecute = false

        showCardScannerCallsCount = 0
        showCardScannerReceivedArguments = nil
        showCardScannerReceivedInvocations = []
        showCardScannerCompletionClosureInput = nil

        openCardPaymentListCallsCount = 0
        openCardPaymentListReceivedArguments = nil
        openCardPaymentListReceivedInvocations = []
    }
}
