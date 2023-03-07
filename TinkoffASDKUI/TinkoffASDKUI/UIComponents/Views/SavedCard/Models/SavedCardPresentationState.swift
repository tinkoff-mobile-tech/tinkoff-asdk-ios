//
//  SavedCardPresentationState.swift
//  TinkoffASDKUI
//
//  Created by r.akhmadeev on 26.01.2023.
//

import Foundation
import TinkoffASDKCore

enum SavedCardPresentationState: Equatable {
    case idle
    case selected(card: PaymentCard, hasAnotherCards: Bool = true)
}

extension SavedCardPresentationState {
    var isIdle: Bool {
        switch self {
        case .idle:
            return true
        default:
            return false
        }
    }

    var isSelected: Bool {
        switch self {
        case .selected:
            return true
        default:
            return false
        }
    }
}
