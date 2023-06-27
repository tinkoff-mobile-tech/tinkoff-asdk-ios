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
    var getCardListCompletionClosureInput: Result<[PaymentCard], Error>?
    var getCardListReturnValue = CancellableMock()

    @discardableResult
    func getCardList(data: GetCardListData, completion: @escaping (_ result: Result<[PaymentCard], Error>) -> Void) -> Cancellable {
        getCardListCallsCount += 1
        let arguments = (data, completion)
        getCardListReceivedArguments = arguments
        getCardListReceivedInvocations.append(arguments)
        if let getCardListCompletionClosureInput = getCardListCompletionClosureInput {
            completion(getCardListCompletionClosureInput)
        }
        return getCardListReturnValue
    }

    // MARK: - removeCard

    typealias RemoveCardArguments = (data: RemoveCardData, completion: (_ result: Result<RemoveCardPayload, Error>) -> Void)

    var removeCardCallsCount = 0
    var removeCardReceivedArguments: RemoveCardArguments?
    var removeCardReceivedInvocations: [RemoveCardArguments] = []
    var removeCardCompletionClosureInput: Result<RemoveCardPayload, Error>?
    var removeCardReturnValue = CancellableMock()

    @discardableResult
    func removeCard(data: RemoveCardData, completion: @escaping (_ result: Result<RemoveCardPayload, Error>) -> Void) -> Cancellable {
        removeCardCallsCount += 1
        let arguments = (data, completion)
        removeCardReceivedArguments = arguments
        removeCardReceivedInvocations.append(arguments)
        if let removeCardCompletionClosureInput = removeCardCompletionClosureInput {
            completion(removeCardCompletionClosureInput)
        }
        return removeCardReturnValue
    }
}
