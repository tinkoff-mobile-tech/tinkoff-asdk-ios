//
//  MockCardListViewInput.swift
//  TinkoffASDKUI-Unit-Tests
//
//  Created by Ivan Glushko on 19.12.2022.
//

import Foundation

@testable import TinkoffASDKCore
@testable import TinkoffASDKUI

final class MockCardListViewInput: ICardListViewInput {

    var reloadCallCounter = 0
    var reloadStub: ([CardListSection]) -> Void = { _ in }
    func reload(sections: [CardListSection]) {
        reloadCallCounter += 1
        reloadStub(sections)
    }

    var deleteItemsCallCounter = 0
    var deleteItemsStub: ([IndexPath]) -> Void = { _ in }
    func deleteItems(at: [IndexPath]) {
        deleteItemsCallCounter += 1
        deleteItemsStub(at)
    }

    var showNoCardsStubCallCounter = 0
    func showNoCardsStub() {
        showNoCardsStubCallCounter += 1
    }

    var showNoNetworkStubCallCounter = 0
    func showNoNetworkStub() {
        showNoNetworkStubCallCounter += 1
    }

    var showServerErrorStubCallCounter = 0
    func showServerErrorStub() {
        showServerErrorStubCallCounter += 1
    }

    var removeCallCounter = 0
    var removeStub: (CardList.Card) -> Void = { _ in }
    func remove(card: CardList.Card) {
        removeCallCounter += 1
        removeStub(card)
    }

    var showCallCounter = 0
    var showStub: (CardList.Alert) -> Void = { _ in }
    func show(alert: CardList.Alert) {
        showCallCounter += 1
        showStub(alert)
    }

    var disableViewUserInteractionCallCounter = 0
    func disableViewUserInteraction() {
        disableViewUserInteractionCallCounter += 1
    }

    var enableViewUserInteractionCallCounter = 0
    func enableViewUserInteraction() {
        enableViewUserInteractionCallCounter += 1
    }

    var showShimmerCallCounter = 0
    func showShimmer() {
        showShimmerCallCounter += 1
    }

    var showStubCallCounter = 0
    var showStubStub: (StubMode) -> Void = { _ in }
    func showStub(mode: StubMode) {
        showStubCallCounter += 1
        showStubStub(mode)
    }

    var hideStubCallCounter = 0
    func hideStub() {
        hideStubCallCounter += 1
    }

    var dismissCallCounter = 0
    func dismiss() {
        dismissCallCounter += 1
    }

    var showDoneEditingButtonCallCounter = 0
    func showDoneEditingButton() {
        showDoneEditingButtonCallCounter += 1
    }

    var showEditButtonCallCounter = 0
    func showEditButton() {
        showEditButtonCallCounter += 1
    }

    var showNativeAlertCallCounter = 0
    var showNativeAlertStub: (String?, String?, String?) -> Void = { _, _, _ in }
    func showNativeAlert(title: String?, message: String?, buttonTitle: String?) {
        showNativeAlertCallCounter += 1
        showNativeAlertStub(title, message, buttonTitle)
    }

    var showLoadingSnackbarCallCounter = 0
    var showLoadingSnackbarStub: (String?) -> Void = { _ in }
    func showLoadingSnackbar(text: String?) {
        showLoadingSnackbarCallCounter += 1
        showLoadingSnackbarStub(text)
    }

    var hideLoadingSnackbarCallCounter = 0
    func hideLoadingSnackbar() {
        hideLoadingSnackbarCallCounter += 1
    }

    var hideShimmerCallCounter = 0
    var hideShimmerStub: (Result<[PaymentCard], Error>) -> Void = { _ in }
    func hideShimmer(fetchCardsResult: Result<[TinkoffASDKCore.PaymentCard], Error>) {
        hideShimmerCallCounter += 1
        hideShimmerStub(fetchCardsResult)
    }

    var showAddedCardSnackbarCallCounter = 0
    var showAddedCardSnackbarStub: (String) -> Void = { _ in }
    func showAddedCardSnackbar(cardMaskedPan: String) {
        showAddedCardSnackbarCallCounter += 1
    }
}
