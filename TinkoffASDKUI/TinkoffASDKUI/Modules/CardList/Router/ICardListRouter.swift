//
//  ICardListRouter.swift
//  TinkoffASDKUI
//
//  Created by r.akhmadeev on 22.02.2023.
//

import Foundation

protocol ICardListRouter {
    func openAddNewCard(customerKey: String, output: IAddNewCardPresenterOutput?)
    func openCardPayment()
}
