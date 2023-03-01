//
//  ISavedCardViewPresenterOutput.swift
//  TinkoffASDKUI
//
//  Created by r.akhmadeev on 25.01.2023.
//

import Foundation
import TinkoffASDKCore

protocol ISavedCardViewPresenterOutput: AnyObject {
    func savedCardPresenter(
        _ presenter: SavedCardViewPresenter,
        didRequestReplacementFor paymentCard: PaymentCard
    )

    func savedCardPresenter(
        _ presenter: SavedCardViewPresenter,
        didUpdateCVC cvc: String,
        isValid: Bool
    )
}
