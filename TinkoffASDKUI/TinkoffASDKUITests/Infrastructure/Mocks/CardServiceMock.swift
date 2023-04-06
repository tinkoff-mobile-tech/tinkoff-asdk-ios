//
//  CardServiceMock.swift
//  TinkoffASDKUI-Unit-Tests
//
//  Created by Ivan Glushko on 30.03.2023
//

import TinkoffASDKCore
@testable import TinkoffASDKUI

final class CardServiceMock: ICardService {

    // MARK: - getCardList

    typealias GetCardListArguments = (data: GetCardListData, completion: (_ result: Result<[PaymentCard], Error>) -> Void)

    var getCardListCallsCount = 0
    var getCardListReceivedArguments: GetCardListArguments?
    var getCardListReceivedInvocations: [GetCardListArguments] = []
    var getCardListReturnValue: Cancellable!
    var getCardListCompletionStub: Result<[PaymentCard], Error>?

    @discardableResult
    func getCardList(data: GetCardListData, completion: @escaping (_ result: Result<[PaymentCard], Error>) -> Void) -> Cancellable {
        getCardListCallsCount += 1
        let arguments = (data, completion)
        getCardListReceivedArguments = arguments
        getCardListReceivedInvocations.append(arguments)
        if let getCardListCompletionStub = getCardListCompletionStub {
            completion(getCardListCompletionStub)
        }
        return getCardListReturnValue
    }

    // MARK: - removeCard

    typealias RemoveCardArguments = (data: RemoveCardData, completion: (_ result: Result<RemoveCardPayload, Error>) -> Void)

    var removeCardCallsCount = 0
    var removeCardReceivedArguments: RemoveCardArguments?
    var removeCardReceivedInvocations: [RemoveCardArguments] = []
    var removeCardReturnValue: Cancellable!

    @discardableResult
    func removeCard(data: RemoveCardData, completion: @escaping (_ result: Result<RemoveCardPayload, Error>) -> Void) -> Cancellable {
        removeCardCallsCount += 1
        let arguments = (data, completion)
        removeCardReceivedArguments = arguments
        removeCardReceivedInvocations.append(arguments)
        return removeCardReturnValue
    }
}
