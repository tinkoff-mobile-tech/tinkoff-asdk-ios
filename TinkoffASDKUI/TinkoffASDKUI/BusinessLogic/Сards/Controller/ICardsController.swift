//
//  ICardsController.swift
//  TinkoffASDKUI
//
//  Created by r.akhmadeev on 19.02.2023.
//

import Foundation
import TinkoffASDKCore

public protocol ICardsController: AnyObject {
    var webFlowDelegate: ThreeDSWebFlowDelegate? { get set }

    func addCard(options: AddCardOptions, completion: @escaping (AddCardResult) -> Void)
    func removeCard(cardId: String, completion: @escaping (Result<RemoveCardPayload, Error>) -> Void)
    func getCards(completion: @escaping (Result<[PaymentCard], Error>) -> Void)
}
