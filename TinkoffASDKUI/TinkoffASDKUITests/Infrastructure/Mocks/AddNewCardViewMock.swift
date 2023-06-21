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

    var underlyingIsLoading: Bool = false

    // MARK: - reloadCollection

    var reloadCollectionCallsCount = 0
    var reloadCollectionReceivedArguments: [AddNewCardSection]?
    var reloadCollectionReceivedInvocations: [[AddNewCardSection]] = []

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

    var setAddButtonCallCounter = 0
    var setAddButtonArguments: SetAddButtonArguments?

    func setAddButton(enabled: Bool, animated: Bool) {
        setAddButtonCallCounter += 1
        setAddButtonArguments = (enabled, animated)
    }

    // MARK: - activateCardField

    var activateCardFieldCallsCount = 0

    func activateCardField() {
        activateCardFieldCallsCount += 1
    }

    // MARK: - showOkNativeAlert

    var showOkNativeAlertCallsCount = 0
    var showOkNativeAlertReceivedArguments: OkAlertData?
    var showOkNativeAlertReceivedInvocations: [OkAlertData] = []

    func showOkNativeAlert(data: OkAlertData) {
        showOkNativeAlertCallsCount += 1
        let arguments = data
        showOkNativeAlertReceivedArguments = arguments
        showOkNativeAlertReceivedInvocations.append(arguments)
    }

    var showCardScannerCallsCount = 0
    var showCardScannerCompletionStub: (cardNumber: String?, expiration: String?, cvc: String?)?
    var showCardScannerReceivedArguments: CardScannerCompletion?
    var showCardScannerReceivedInvocations: [CardScannerCompletion] = []
    func showCardScanner(completion: @escaping CardScannerCompletion) {
        showCardScannerCallsCount += 1
        showCardScannerReceivedArguments = completion
        showCardScannerReceivedInvocations.append(completion)
        if let stub = showCardScannerCompletionStub {
            completion(stub.cardNumber, stub.expiration, stub.cvc)
        }
    }
}
