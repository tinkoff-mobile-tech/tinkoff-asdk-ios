//
//  SavedCardPresentationState.swift
//  TinkoffASDKUI
//
//  Created by r.akhmadeev on 26.01.2023.
//

import Foundation
import TinkoffASDKCore

enum SavedCardPresentationState {
    case idle
    case selected(card: PaymentCard, hasAnotherCards: Bool)
}
