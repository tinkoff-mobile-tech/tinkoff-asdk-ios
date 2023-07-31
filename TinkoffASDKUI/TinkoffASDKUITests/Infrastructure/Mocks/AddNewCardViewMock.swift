//
//  AddNewCardViewMock.swift
//  TinkoffASDKUI-Unit-Tests
//
//  Created by Ivan Glushko on 27.03.2023.
//

@testable import TinkoffASDKUI

final class AddNewCardViewMock: IAddNewCardView {

    var isLoading: Bool {
        get { return underlyingIsLoading }
        set(value) { underlyingIsLoading = value }
    }

    var underlyingIsLoading = false

    // MARK: - reloadCollection

    typealias ReloadCollectionArguments = [AddNewCardSection]

    var reloadCollectionCallsCount = 0
    var reloadCollectionReceivedArguments: ReloadCollectionArguments?
    var reloadCollectionReceivedInvocations: [ReloadCollectionArguments?] = []

    func reloadCollection(sections: [AddNewCardSection]) {
        reloadCollectionCallsCount += 1
        let arguments = sections
        reloadCollectionReceivedArguments = arguments
        reloadCollectionReceivedInvocations.append(arguments)
    }

    // MARK: - showLoadingState

    var showLoadingStateCallsCount = 0

    func showLoadingState() {
        showLoadingStateCallsCount += 1
    }

    // MARK: - hideLoadingState

    var hideLoadingStateCallsCount = 0

    func hideLoadingState() {
        hideLoadingStateCallsCount += 1
    }

    // MARK: - closeScreen

    var closeScreenCallsCount = 0

    func closeScreen() {
        closeScreenCallsCount += 1
    }

    // MARK: - setAddButton

    typealias SetAddButtonArguments = (enabled: Bool, animated: Bool)

    var setAddButtonCallsCount = 0
    var setAddButtonReceivedArguments: SetAddButtonArguments?
    var setAddButtonReceivedInvocations: [SetAddButtonArguments?] = []

    func setAddButton(enabled: Bool, animated: Bool) {
        setAddButtonCallsCount += 1
        let arguments = (enabled, animated)
        setAddButtonReceivedArguments = arguments
        setAddButtonReceivedInvocations.append(arguments)
    }

    // MARK: - activateCardField

    var activateCardFieldCallsCount = 0

    func activateCardField() {
        activateCardFieldCallsCount += 1
    }

    // MARK: - showOkNativeAlert

    typealias ShowOkNativeAlertArguments = OkAlertData

    var showOkNativeAlertCallsCount = 0
    var showOkNativeAlertReceivedArguments: ShowOkNativeAlertArguments?
    var showOkNativeAlertReceivedInvocations: [ShowOkNativeAlertArguments?] = []

    func showOkNativeAlert(data: OkAlertData) {
        showOkNativeAlertCallsCount += 1
        let arguments = data
        showOkNativeAlertReceivedArguments = arguments
        showOkNativeAlertReceivedInvocations.append(arguments)
    }

    // MARK: - showCardScanner

    typealias ShowCardScannerArguments = CardScannerCompletion

    var showCardScannerCallsCount = 0
    var showCardScannerReceivedArguments: ShowCardScannerArguments?
    var showCardScannerReceivedInvocations: [ShowCardScannerArguments?] = []
    var showCardScannerCompletionClosureInput: (String?, String?, String?)?

    func showCardScanner(completion: @escaping CardScannerCompletion) {
        showCardScannerCallsCount += 1
        let arguments = completion
        showCardScannerReceivedArguments = arguments
        showCardScannerReceivedInvocations.append(arguments)
        if let showCardScannerCompletionClosureInput = showCardScannerCompletionClosureInput {
            completion(
                showCardScannerCompletionClosureInput.0,
                showCardScannerCompletionClosureInput.1,
                showCardScannerCompletionClosureInput.2
            )
        }
    }
}

// MARK: - Resets

extension AddNewCardViewMock {
    func fullReset() {
        reloadCollectionCallsCount = 0
        reloadCollectionReceivedArguments = nil
        reloadCollectionReceivedInvocations = []

        showLoadingStateCallsCount = 0

        hideLoadingStateCallsCount = 0

        closeScreenCallsCount = 0

        setAddButtonCallsCount = 0
        setAddButtonReceivedArguments = nil
        setAddButtonReceivedInvocations = []

        activateCardFieldCallsCount = 0

        showOkNativeAlertCallsCount = 0
        showOkNativeAlertReceivedArguments = nil
        showOkNativeAlertReceivedInvocations = []

        showCardScannerCallsCount = 0
        showCardScannerReceivedArguments = nil
        showCardScannerReceivedInvocations = []
        showCardScannerCompletionClosureInput = nil
    }
}
