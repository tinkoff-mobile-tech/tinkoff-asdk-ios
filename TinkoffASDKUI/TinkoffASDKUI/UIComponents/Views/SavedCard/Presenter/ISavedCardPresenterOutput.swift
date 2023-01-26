//
//  ISavedCardPresenterOutput.swift
//  TinkoffASDKUI
//
//  Created by r.akhmadeev on 25.01.2023.
//

import Foundation
import TinkoffASDKCore

protocol ISavedCardPresenterOutput: AnyObject {
    func savedCardPresenter(
        _ presenter: SavedCardPresenter,
        didRequestReplacementFor paymentCard: PaymentCard
    )

    func savedCardPresenter(
        _ presenter: SavedCardPresenter,
        didUpdateCVC cvc: String,
        isValid: Bool
    )
}
