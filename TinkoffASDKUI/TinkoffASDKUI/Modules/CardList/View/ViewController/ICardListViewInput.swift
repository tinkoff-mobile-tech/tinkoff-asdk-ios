//
//  ICardListViewInput.swift
//  TinkoffASDKUI
//
//  Created by r.akhmadeev on 22.02.2023.
//

import Foundation
import TinkoffASDKCore

protocol ICardListViewInput: AnyObject {
    func reload(sections: [CardListSection])
    func deleteItems(at: [IndexPath])
    func disableViewUserInteraction()
    func enableViewUserInteraction()
    func showShimmer()
    func hideShimmer(fetchCardsResult: Result<[PaymentCard], Error>)
    func showStub(mode: StubMode)
    func hideStub()
    func closeScreen()
    func showDoneEditingButton()
    func showEditButton()
    func hideRightBarButton()
    func showNativeAlert(data: OkAlertData)
    func showRemovingCardSnackBar(text: String?)
    func hideLoadingSnackbar()
    func showAddedCardSnackbar(cardMaskedPan: String)
}
