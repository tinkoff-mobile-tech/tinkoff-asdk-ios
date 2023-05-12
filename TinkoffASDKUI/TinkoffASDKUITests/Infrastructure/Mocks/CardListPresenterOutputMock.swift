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
    var cardListDidUpdateCalls: [[PaymentCard]] = []

    func cardList(didUpdate cards: [PaymentCard]) {
        cardListDidUpdateCalls.append(cards)
    }

    var cardListWillCloseAfterSelectingCalls: [PaymentCard] = []

    func cardList(willCloseAfterSelecting card: TinkoffASDKCore.PaymentCard) {
        cardListWillCloseAfterSelectingCalls.append(card)
    }
}
