//
//  ISavedCardPresenterInput.swift
//  TinkoffASDKUI
//
//  Created by r.akhmadeev on 26.01.2023.
//

import Foundation
import TinkoffASDKCore

protocol ISavedCardPresenterInput: AnyObject {
    var presentationState: SavedCardPresentationState { get set }
    var isValid: Bool { get }
    var cardId: String? { get }
    var cvc: String? { get }
}

extension ISavedCardPresenterInput {
    /// Обновляет состояние на основе полученного или измененного списка карта
    func updatePresentationState(for cards: [PaymentCard]) {
        guard let firstCard = cards.first else {
            // список карт пуст, отображать нечего
            return presentationState = .idle
        }

        switch presentationState {
        case let .selected(selectedCard) where cards.contains(selectedCard):
            // выбранная карта по-прежнему находится в списке, поэтому ничего не меняется
            break
        case .selected, .idle:
            // выбранная карта была удалена или в пустой список была добавлена новая карта
            presentationState = .selected(card: firstCard)
        }
    }
}
