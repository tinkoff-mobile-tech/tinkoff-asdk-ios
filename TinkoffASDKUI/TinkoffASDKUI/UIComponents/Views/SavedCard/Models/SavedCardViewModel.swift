//
//  SavedCardViewModel.swift
//  TinkoffASDKUI
//
//  Created by r.akhmadeev on 25.01.2023.
//

import Foundation

struct SavedCardViewModel {
    struct CVCField {
        let text: String
        let isValid: Bool
    }

    let iconModel: DynamicIconCardView.Model
    let cardName: String
    let actionDescription: String?
    let cvcField: CVCField?
}
