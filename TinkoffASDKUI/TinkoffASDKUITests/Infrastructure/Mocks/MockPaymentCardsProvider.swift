//
//  MockPaymentCardsProvider.swift
//  TinkoffASDKUI-Unit-Tests
//
//  Created by Ivan Glushko on 19.12.2022.
//

@testable import TinkoffASDKCore
@testable import TinkoffASDKUI

import Foundation

final class MockPaymentCardsProvider: IPaymentCardsProvider {

    // MARK: - fetchActiveCardsStub

    var fetchActiveCardsCallCounter = 0
    var fetchActiveCardsStub: (@escaping (Result<[PaymentCard], Error>) -> Void) -> Void = { _ in }
    func fetchActiveCards(_ completion: @escaping (Result<[PaymentCard], Error>) -> Void) {
        fetchActiveCardsCallCounter += 1
        fetchActiveCardsStub(completion)
    }

    // MARK: - deactivateCard

    var deactivateCardCallCounter = 0
    var deactivateCardStub: (String, @escaping (Result<Void, Error>) -> Void) -> Void = { _, _ in }
    func deactivateCard(cardId: String, completion: @escaping (Result<Void, Error>) -> Void) {
        deactivateCardCallCounter += 1
        deactivateCardStub(cardId, completion)
    }
}
