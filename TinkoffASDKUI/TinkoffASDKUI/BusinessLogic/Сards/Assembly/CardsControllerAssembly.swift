//
//  CardsControllerAssembly.swift
//  TinkoffASDKUI
//
//  Created by r.akhmadeev on 18.02.2023.
//

import Foundation
import TinkoffASDKCore

final class CardsControllerAssembly: ICardsControllerAssembly {
    // MARK: Dependencies

    private let coreSDK: AcquiringSdk
    private let addCardControllerAssembly: IAddCardControllerAssembly

    // MARK: Init

    init(coreSDK: AcquiringSdk, addCardControllerAssembly: IAddCardControllerAssembly) {
        self.coreSDK = coreSDK
        self.addCardControllerAssembly = addCardControllerAssembly
    }

    // MARK: ICardsControllerAssembly

    func cardsController(customerKey: String, addCardOptions: AddCardOptions) -> ICardsController {
        CardsController(
            cardService: coreSDK,
            addCardController: addCardControllerAssembly.addCardController(
                customerKey: customerKey,
                addCardOptions: addCardOptions
            )
        )
    }
}
