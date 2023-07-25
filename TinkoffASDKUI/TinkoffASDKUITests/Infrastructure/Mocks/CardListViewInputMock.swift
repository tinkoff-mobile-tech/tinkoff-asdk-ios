//
//  CardListViewInputMock.swift
//  TinkoffASDKUI-Unit-Tests
//
//  Created by Ivan Glushko on 19.12.2022.
//

import Foundation

@testable import TinkoffASDKCore
@testable import TinkoffASDKUI

final class CardListViewInputMock: ICardListViewInput {

    // MARK: - reload

    typealias ReloadArguments = [CardListSection]

    var reloadCallsCount = 0
    var reloadReceivedArguments: ReloadArguments?
    var reloadReceivedInvocations: [ReloadArguments?] = []

    func reload(sections: [CardListSection]) {
        reloadCallsCount += 1
        let arguments = sections
        reloadReceivedArguments = arguments
        reloadReceivedInvocations.append(arguments)
    }

    // MARK: - deleteItems

    typealias DeleteItemsArguments = [IndexPath]

    var deleteItemsCallsCount = 0
    var deleteItemsReceivedArguments: DeleteItemsArguments?
    var deleteItemsReceivedInvocations: [DeleteItemsArguments?] = []

    func deleteItems(at: [IndexPath]) {
        deleteItemsCallsCount += 1
        let arguments = at
        deleteItemsReceivedArguments = arguments
        deleteItemsReceivedInvocations.append(arguments)
    }

    // MARK: - disableViewUserInteraction

    var disableViewUserInteractionCallsCount = 0

    func disableViewUserInteraction() {
        disableViewUserInteractionCallsCount += 1
    }

    // MARK: - enableViewUserInteraction

    var enableViewUserInteractionCallsCount = 0

    func enableViewUserInteraction() {
        enableViewUserInteractionCallsCount += 1
    }

    // MARK: - showShimmer

    var showShimmerCallsCount = 0

    func showShimmer() {
        showShimmerCallsCount += 1
    }

    // MARK: - hideShimmer

    typealias HideShimmerArguments = Result<[PaymentCard], Error>

    var hideShimmerCallsCount = 0
    var hideShimmerReceivedArguments: HideShimmerArguments?
    var hideShimmerReceivedInvocations: [HideShimmerArguments?] = []

    func hideShimmer(fetchCardsResult: Result<[PaymentCard], Error>) {
        hideShimmerCallsCount += 1
        let arguments = fetchCardsResult
        hideShimmerReceivedArguments = arguments
        hideShimmerReceivedInvocations.append(arguments)
    }

    // MARK: - showStub

    typealias ShowStubArguments = StubMode

    var showStubCallsCount = 0
    var showStubReceivedArguments: ShowStubArguments?
    var showStubReceivedInvocations: [ShowStubArguments?] = []

    func showStub(mode: StubMode) {
        showStubCallsCount += 1
        let arguments = mode
        showStubReceivedArguments = arguments
        showStubReceivedInvocations.append(arguments)
    }

    // MARK: - hideStub

    var hideStubCallsCount = 0

    func hideStub() {
        hideStubCallsCount += 1
    }

    // MARK: - closeScreen

    var closeScreenCallsCount = 0

    func closeScreen() {
        closeScreenCallsCount += 1
    }

    // MARK: - showDoneEditingButton

    var showDoneEditingButtonCallsCount = 0

    func showDoneEditingButton() {
        showDoneEditingButtonCallsCount += 1
    }

    // MARK: - showEditButton

    var showEditButtonCallsCount = 0

    func showEditButton() {
        showEditButtonCallsCount += 1
    }

    // MARK: - hideRightBarButton

    var hideRightBarButtonCallsCount = 0

    func hideRightBarButton() {
        hideRightBarButtonCallsCount += 1
    }

    // MARK: - showNativeAlert

    typealias ShowNativeAlertArguments = OkAlertData

    var showNativeAlertCallsCount = 0
    var showNativeAlertReceivedArguments: ShowNativeAlertArguments?
    var showNativeAlertReceivedInvocations: [ShowNativeAlertArguments?] = []

    func showNativeAlert(data: OkAlertData) {
        showNativeAlertCallsCount += 1
        let arguments = data
        showNativeAlertReceivedArguments = arguments
        showNativeAlertReceivedInvocations.append(arguments)
    }

    // MARK: - showRemovingCardSnackBar

    typealias ShowRemovingCardSnackBarArguments = String

    var showRemovingCardSnackBarCallsCount = 0
    var showRemovingCardSnackBarReceivedArguments: ShowRemovingCardSnackBarArguments?
    var showRemovingCardSnackBarReceivedInvocations: [ShowRemovingCardSnackBarArguments?] = []

    func showRemovingCardSnackBar(text: String?) {
        showRemovingCardSnackBarCallsCount += 1
        let arguments = text
        showRemovingCardSnackBarReceivedArguments = arguments
        showRemovingCardSnackBarReceivedInvocations.append(arguments)
    }

    // MARK: - hideLoadingSnackbar

    var hideLoadingSnackbarCallsCount = 0

    func hideLoadingSnackbar() {
        hideLoadingSnackbarCallsCount += 1
    }

    // MARK: - showAddedCardSnackbar

    typealias ShowAddedCardSnackbarArguments = String

    var showAddedCardSnackbarCallsCount = 0
    var showAddedCardSnackbarReceivedArguments: ShowAddedCardSnackbarArguments?
    var showAddedCardSnackbarReceivedInvocations: [ShowAddedCardSnackbarArguments?] = []

    func showAddedCardSnackbar(cardMaskedPan: String) {
        showAddedCardSnackbarCallsCount += 1
        let arguments = cardMaskedPan
        showAddedCardSnackbarReceivedArguments = arguments
        showAddedCardSnackbarReceivedInvocations.append(arguments)
    }
}

// MARK: - Resets

extension CardListViewInputMock {
    func fullReset() {
        reloadCallsCount = 0
        reloadReceivedArguments = nil
        reloadReceivedInvocations = []

        deleteItemsCallsCount = 0
        deleteItemsReceivedArguments = nil
        deleteItemsReceivedInvocations = []

        disableViewUserInteractionCallsCount = 0

        enableViewUserInteractionCallsCount = 0

        showShimmerCallsCount = 0

        hideShimmerCallsCount = 0
        hideShimmerReceivedArguments = nil
        hideShimmerReceivedInvocations = []

        showStubCallsCount = 0
        showStubReceivedArguments = nil
        showStubReceivedInvocations = []

        hideStubCallsCount = 0

        closeScreenCallsCount = 0

        showDoneEditingButtonCallsCount = 0

        showEditButtonCallsCount = 0

        hideRightBarButtonCallsCount = 0

        showNativeAlertCallsCount = 0
        showNativeAlertReceivedArguments = nil
        showNativeAlertReceivedInvocations = []

        showRemovingCardSnackBarCallsCount = 0
        showRemovingCardSnackBarReceivedArguments = nil
        showRemovingCardSnackBarReceivedInvocations = []

        hideLoadingSnackbarCallsCount = 0

        showAddedCardSnackbarCallsCount = 0
        showAddedCardSnackbarReceivedArguments = nil
        showAddedCardSnackbarReceivedInvocations = []
    }
}
