//
//  ISavedCardPresenterInput.swift
//  TinkoffASDKUI
//
//  Created by r.akhmadeev on 26.01.2023.
//

import Foundation

protocol ISavedCardPresenterInput: AnyObject {
    var presentationState: SavedCardPresentationState { get set }
    var isValid: Bool { get }
    var cardId: String? { get }
    var cvc: String? { get }
}
