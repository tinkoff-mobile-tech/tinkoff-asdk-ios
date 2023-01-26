//
//  SavedCardViewModel.swift
//  TinkoffASDKUI
//
//  Created by r.akhmadeev on 25.01.2023.
//

import Foundation

struct SavedCardViewModel {
    let iconModel: DynamicIconCardView.Model
    let cardName: String
    let actionDescription: String?

    init(
        iconModel: DynamicIconCardView.Model = DynamicIconCardView.Model(),
        cardName: String = "",
        actionDescription: String? = nil
    ) {
        self.iconModel = iconModel
        self.cardName = cardName
        self.actionDescription = actionDescription
    }
}
