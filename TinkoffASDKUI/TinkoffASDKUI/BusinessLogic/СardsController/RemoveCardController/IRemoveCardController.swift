//
//  IRemoveCardController.swift
//  TinkoffASDKUI
//
//  Created by r.akhmadeev on 16.02.2023.
//

import Foundation

protocol IRemoveCardController {
    func removeCard(cardId: String, _ completion: @escaping (Result<Void, Error>) -> Void)
}
