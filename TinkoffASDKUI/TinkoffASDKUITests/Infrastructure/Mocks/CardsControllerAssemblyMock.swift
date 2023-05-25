//
//  CardsControllerAssemblyMock.swift
//  Pods
//
//  Created by Ivan Glushko on 25.05.2023.
//

@testable import TinkoffASDKUI

final class CardsControllerAssemblyMock: ICardsControllerAssembly {

    // MARK: - cardsController

    var cardsControllerCallsCount = 0
    var cardsControllerReceivedArguments: String?
    var cardsControllerReceivedInvocations: [String] = []
    var cardsControllerReturnValue: ICardsController!

    func cardsController(customerKey: String) -> ICardsController {
        cardsControllerCallsCount += 1
        let arguments = customerKey
        cardsControllerReceivedArguments = arguments
        cardsControllerReceivedInvocations.append(arguments)
        return cardsControllerReturnValue
    }
}
