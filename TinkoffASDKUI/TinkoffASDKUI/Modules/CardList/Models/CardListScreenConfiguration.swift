//
//  CardListScreenConfiguration.swift
//  TinkoffASDKUI
//
//  Created by r.akhmadeev on 28.02.2023.
//

import Foundation

struct CardListScreenConfiguration {
    enum UseCase {
        case cardList
        case cardPaymentList
    }

    let useCase: UseCase
    var selectedCardId: String?
}

extension CardListScreenConfiguration {
    var listItemsAreSelectable: Bool {
        switch useCase {
        case .cardList:
            return false
        case .cardPaymentList:
            return true
        }
    }

    var navigationTitle: String {
        switch useCase {
        case .cardList:
            return Loc.Acquiring.CardList.screenTitle
        case .cardPaymentList:
            return Loc.CardList.Screen.Title.paymentByCard
        }
    }

    var newCardTitle: String {
        switch useCase {
        case .cardList:
            return Loc.Acquiring.CardList.addCard
        case .cardPaymentList:
            return Loc.CardList.Button.anotherCard
        }
    }
}
