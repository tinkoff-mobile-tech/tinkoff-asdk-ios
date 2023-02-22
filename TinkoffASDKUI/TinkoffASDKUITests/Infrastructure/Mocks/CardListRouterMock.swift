//
//  CardListRouterMock.swift
//  TinkoffASDKUI-Unit-Tests
//
//  Created by r.akhmadeev on 22.02.2023.
//

@testable import TinkoffASDKUI

final class CardListRouterMock: ICardListRouter {
    var openAddNewCardsCallsCount = 0

    func openAddNewCard(customerKey: String, output: IAddNewCardPresenterOutput?) {
        openAddNewCardsCallsCount += 1
    }
}
