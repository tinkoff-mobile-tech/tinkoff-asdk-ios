//
//  ICardsController.swift
//  TinkoffASDKUI
//
//  Created by r.akhmadeev on 19.02.2023.
//

import Foundation
import TinkoffASDKCore

protocol ICardsController: AnyObject {
    var uiProvider: PaymentControllerUIProvider? { get set }
    
    func addCard(options: AddCardOptions, completion: @escaping (AddNewCardResult) -> Void)
    func removeCard(cardId: String, completion: @escaping (Result<RemoveCardPayload, Error>) -> Void)
    func getCards(completion: @escaping (Result<[PaymentCard], Error>) -> Void)
}
