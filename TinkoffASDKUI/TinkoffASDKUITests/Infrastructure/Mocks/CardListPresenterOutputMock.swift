//
//  CardListPresenterOutputMock.swift
//  TinkoffASDKUI-Unit-Tests
//
//  Created by r.akhmadeev on 28.02.2023.
//

import Foundation
@testable import TinkoffASDKCore
@testable import TinkoffASDKUI

final class CardListPresenterOutputMock: ICardListPresenterOutput {

    // MARK: - cardListDidUpdate

    typealias CardListDidUpdateArguments = [PaymentCard]

    var cardListDidUpdateCallsCount = 0
    var cardListDidUpdateReceivedArguments: CardListDidUpdateArguments?
    var cardListDidUpdateReceivedInvocations: [CardListDidUpdateArguments?] = []

    func cardList(didUpdate cards: [PaymentCard]) {
        cardListDidUpdateCallsCount += 1
        let arguments = cards
        cardListDidUpdateReceivedArguments = arguments
        cardListDidUpdateReceivedInvocations.append(arguments)
    }

    // MARK: - cardListWillCloseAfterSelecting

    typealias CardListWillCloseAfterSelectingArguments = PaymentCard

    var cardListWillCloseAfterSelectingCallsCount = 0
    var cardListWillCloseAfterSelectingReceivedArguments: CardListWillCloseAfterSelectingArguments?
    var cardListWillCloseAfterSelectingReceivedInvocations: [CardListWillCloseAfterSelectingArguments?] = []

    func cardList(willCloseAfterSelecting card: PaymentCard) {
        cardListWillCloseAfterSelectingCallsCount += 1
        let arguments = card
        cardListWillCloseAfterSelectingReceivedArguments = arguments
        cardListWillCloseAfterSelectingReceivedInvocations.append(arguments)
    }
}

// MARK: - Resets

extension CardListPresenterOutputMock {
    func fullReset() {
        cardListDidUpdateCallsCount = 0
        cardListDidUpdateReceivedArguments = nil
        cardListDidUpdateReceivedInvocations = []

        cardListWillCloseAfterSelectingCallsCount = 0
        cardListWillCloseAfterSelectingReceivedArguments = nil
        cardListWillCloseAfterSelectingReceivedInvocations = []
    }
}
