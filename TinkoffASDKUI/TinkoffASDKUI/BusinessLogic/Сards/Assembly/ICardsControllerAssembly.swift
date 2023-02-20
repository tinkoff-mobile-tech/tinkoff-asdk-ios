//
//  ICardsControllerAssembly.swift
//  TinkoffASDKUI
//
//  Created by r.akhmadeev on 19.02.2023.
//

import Foundation

protocol ICardsControllerAssembly {
    func cardsController(customerKey: String) -> ICardsController
}
