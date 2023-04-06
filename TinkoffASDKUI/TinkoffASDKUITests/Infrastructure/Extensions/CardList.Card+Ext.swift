//
//  CardList.Card+Ext.swift
//  Pods-ASDKSample
//
//  Created by Ivan Glushko on 24.03.2023.
//

import Foundation
import TinkoffASDKCore

@testable import TinkoffASDKUI

extension CardList.Card {

    init(from card: PaymentCard) {
        self.init(
            id: card.cardId,
            pan: card.pan,
            cardModel: DynamicIconCardView.Model(),
            bankNameText: "",
            cardNumberText: "",
            isInEditingMode: true,
            hasCheckmarkInNormalMode: true
        )
    }
}
