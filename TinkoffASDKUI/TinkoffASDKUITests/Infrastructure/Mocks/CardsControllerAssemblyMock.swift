//
//  CardsControllerAssemblyMock.swift
//  Pods
//
//  Created by Ivan Glushko on 25.05.2023.
//

@testable import TinkoffASDKUI

final class CardsControllerAssemblyMock: ICardsControllerAssembly {

    // MARK: - cardsController

    typealias CardsControllerArguments = String

    var cardsControllerCallsCount = 0
    var cardsControllerReceivedArguments: CardsControllerArguments?
    var cardsControllerReceivedInvocations: [CardsControllerArguments?] = []
    var cardsControllerReturnValue: ICardsController!

    func cardsController(customerKey: String) -> ICardsController {
        cardsControllerCallsCount += 1
        let arguments = customerKey
        cardsControllerReceivedArguments = arguments
        cardsControllerReceivedInvocations.append(arguments)
        return cardsControllerReturnValue
    }
}

// MARK: - Resets

extension CardsControllerAssemblyMock {
    func fullReset() {
        cardsControllerCallsCount = 0
        cardsControllerReceivedArguments = nil
        cardsControllerReceivedInvocations = []
    }
}
