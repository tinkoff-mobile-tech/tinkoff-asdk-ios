//
//
//  CardAddingController.swift
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

public protocol CardAddingControllerUIProvider: AnyObject {
    /// viewController для модального показа экранов, необходимость в которых может возникнуть в процессе добавления карты
    func sourceViewControllerToPresent() -> UIViewController
}

protocol CardAddingControllerDelegate: AnyObject {
    /// Добавление карты прошло успешно
    func cardAddingController(_ controller: CardAddingController,
                              didFinish: AddCardProcess,
                              state: GetAddCardStatePayload)
    
    /// Добавление карты было отменено
    func cardAddingController(_ controller: CardAddingController,
                              addCardWasCancelled: AddCardProcess)
    
    /// Возникла ошибка в процессе добавления карты
    func cardAddingController(_ controller: CardAddingController,
                              didFailed error: Error)
}

protocol CardAddingController {
    func addCard(cardData: CardData,
                 customerKey: String,
                 checkType: PaymentCardCheckType)
}
