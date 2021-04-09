//
//
//  CardsAssembly.swift
//
//  Copyright (c) 2021 Tinkoff Bank
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//   http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//


import TinkoffASDKCore

final class CardsAssembly {
    
    private let acquiringSDK: AcquiringSdk
    
    private var cardsControllers = [String: CardsController]()
    
    init(acquiringSDK: AcquiringSdk) {
        self.acquiringSDK = acquiringSDK
    }
    
    func getCardsController(customerKey: String) -> CardsController {
        let cardsController = cardsControllers[customerKey] ?? buildCardsController(customerKey: customerKey)
        cardsControllers[customerKey] = cardsController
        return cardsController
    }
}

private extension CardsAssembly {
    func buildCardsController(customerKey: String) -> CardsController {
        
        let addingCardController = buildAddingCardController()
        
        let cardsController = DefaultCardsController(customerKey: customerKey,
                                                    cardsLoader: buildCardsLoader(),
                                                    addingCardController: addingCardController,
                                                    acquiringSDK: acquiringSDK)
        
        addingCardController.delegate = cardsController
        addingCardController.uiProvider = cardsController
        
        return cardsController
    }
    
    func buildCardsLoader() -> CardsLoader {
        DefaultCardsLoader(acquiringSDK: acquiringSDK)
    }
    
    func buildAddingCardController() -> DefaultCardAddingController {
        DefaultCardAddingController(acquiringSDK: acquiringSDK,
                                    threeDSHandler: acquiringSDK.addCard3DSHandler())
    }
    
}
