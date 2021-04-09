//
//
//  CardsController.swift
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

public protocol CardsControllerUIProvider: AnyObject {
    /// viewController для модального показа экранов
    func sourceViewControllerToPresent() -> UIViewController
}

public protocol CardsControllerListener: AnyObject {
    func cardsControllerDidUpdateCards(_ cardsController: CardsController)
}

public enum CardsControllerError: Swift.Error {
    case cancelled
}

public protocol CardsController {
    var customerKey: String { get }
    
    func loadCards(completion: @escaping (Result<[PaymentCard], Error>) -> Void)
    func getCards(predicates: PaymentCardPredicate...) -> [PaymentCard]
    
    func addCard(cardData: CardData,
                 checkType: PaymentCardCheckType,
                 uiProvider: CardsControllerUIProvider,
                 completion: @escaping (Result<PaymentCard?, Error>) -> Void)
    
    func addListener(_ listener: CardsControllerListener)
    func removeListener(_ listener: CardsControllerListener)
}
