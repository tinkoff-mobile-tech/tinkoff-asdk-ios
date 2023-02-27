//
//  ICardListPresenterOutput.swift
//  TinkoffASDKUI
//
//  Created by r.akhmadeev on 22.02.2023.
//

import Foundation
import TinkoffASDKCore

protocol ICardListPresenterOutput: AnyObject {
    func cardList(didUpdate cards: [PaymentCard])
    func cardList(didSelect card: PaymentCard)
    func cardListDidSelectNewCard()
}
