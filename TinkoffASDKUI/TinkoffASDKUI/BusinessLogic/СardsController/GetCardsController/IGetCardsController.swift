//
//  IGetCardsController.swift
//  TinkoffASDKUI
//
//  Created by r.akhmadeev on 16.02.2023.
//

import Foundation
import TinkoffASDKCore

protocol IGetCardsController {
    func getCards(_ completion: @escaping (Result<[PaymentCard], Error>) -> Void)
}
