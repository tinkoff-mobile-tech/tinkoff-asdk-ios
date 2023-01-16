//
//  MockIAddNewCardView.swift
//  TinkoffASDKUI-Unit-Tests
//
//  Created by Ivan Glushko on 28.12.2022.
//

import TinkoffASDKCore
@testable import TinkoffASDKUI

final class MockIAddNewCardView: IAddNewCardView {

    var reloadCollectionCallCounter = 0
    var reloadCollectionStub: ([AddNewCardSection]) -> Void = { _ in }
    func reloadCollection(sections: [AddNewCardSection]) {
        reloadCollectionCallCounter += 1
    }

    var showLoadingStateCallCounter = 0
    func showLoadingState() {
        showLoadingStateCallCounter += 1
    }

    var hideLoadingStateCallCounter = 0
    func hideLoadingState() {
        hideLoadingStateCallCounter += 1
    }

    var notifyAddedCallCounter = 0
    var notifyAddedStub: (PaymentCard) -> Void = { _ in }
    func notifyAdded(card: PaymentCard) {
        notifyAddedCallCounter += 1
        notifyAddedStub(card)
    }

    var closeScreenCallCounter = 0
    func closeScreen() {
        closeScreenCallCounter += 1
    }

    var showAlreadySuchCardErrorNativeAlertCallCounter = 0
    func showAlreadySuchCardErrorNativeAlert() {
        showAlreadySuchCardErrorNativeAlertCallCounter += 1
    }

    var showGenericErrorNativeAlertCallCounter = 0
    func showGenericErrorNativeAlert() {
        showGenericErrorNativeAlertCallCounter += 1
    }

    var disableAddButtonCallCounter = 0
    func disableAddButton() {
        disableAddButtonCallCounter += 1
    }

    var enableAddButtonCallCounter = 0
    func enableAddButton() {
        enableAddButtonCallCounter += 1
    }

    var activateCardFieldCallCounter = 0

    func activateCardField() {
        activateCardFieldCallCounter += 1
    }

    var showOkNativeAlertCallCounter = 0
    var showOkNativeAlertStub: (OkAlertData) -> Void = { _ in }

    func showOkNativeAlert(data: OkAlertData) {
        showOkNativeAlertCallCounter += 1
        showOkNativeAlertStub(data)
    }
}
