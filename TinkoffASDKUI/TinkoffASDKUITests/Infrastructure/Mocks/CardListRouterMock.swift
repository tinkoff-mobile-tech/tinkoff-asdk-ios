//
//  CardListRouterMock.swift
//  TinkoffASDKUI-Unit-Tests
//
//  Created by r.akhmadeev on 22.02.2023.
//

@testable import TinkoffASDKUI

final class CardListRouterMock: ICardListRouter {

    // MARK: - openAddNewCard

    typealias OpenAddNewCardArguments = (customerKey: String, output: IAddNewCardPresenterOutput?)

    var openAddNewCardCallsCount = 0
    var openAddNewCardReceivedArguments: OpenAddNewCardArguments?
    var openAddNewCardReceivedInvocations: [OpenAddNewCardArguments?] = []

    func openAddNewCard(customerKey: String, output: IAddNewCardPresenterOutput?) {
        openAddNewCardCallsCount += 1
        let arguments = (customerKey, output)
        openAddNewCardReceivedArguments = arguments
        openAddNewCardReceivedInvocations.append(arguments)
    }

    // MARK: - openCardPayment

    var openCardPaymentCallsCount = 0

    func openCardPayment() {
        openCardPaymentCallsCount += 1
    }
}

// MARK: - Resets

extension CardListRouterMock {
    func fullReset() {
        openAddNewCardCallsCount = 0
        openAddNewCardReceivedArguments = nil
        openAddNewCardReceivedInvocations = []

        openCardPaymentCallsCount = 0
    }
}
