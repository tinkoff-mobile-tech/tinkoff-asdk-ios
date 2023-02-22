//
//  ICardListPresenterOutput.swift
//  TinkoffASDKUI
//
//  Created by r.akhmadeev on 22.02.2023.
//

import Foundation
import TinkoffASDKCore

protocol ICardListPresenterOutput: AnyObject {
    func cardList(didRemoveCard card: PaymentCard)
    func cardList(didSelect card: PaymentCard)
}
