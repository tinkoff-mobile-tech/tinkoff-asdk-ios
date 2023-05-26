//
//  CardPaymentViewControllerInputMock.swift
//  TinkoffASDKUI-Unit-Tests
//
//  Created by Aleksandr Pravosudov on 19.05.2023.
//

@testable import TinkoffASDKUI

final class CardPaymentViewControllerInputMock: ICardPaymentViewControllerInput {

    // MARK: - startIgnoringInteractionEvents

    var startIgnoringInteractionEventsCallsCount = 0

    func startIgnoringInteractionEvents() {
        startIgnoringInteractionEventsCallsCount += 1
    }

    // MARK: - stopIgnoringInteractionEvents

    var stopIgnoringInteractionEventsCallsCount = 0

    func stopIgnoringInteractionEvents() {
        stopIgnoringInteractionEventsCallsCount += 1
    }

    // MARK: - showActivityIndicator

    var showActivityIndicatorCallsCount = 0
    var showActivityIndicatorReceivedArguments: ActivityIndicatorView.Style?
    var showActivityIndicatorReceivedInvocations: [ActivityIndicatorView.Style] = []

    func showActivityIndicator(with style: ActivityIndicatorView.Style) {
        showActivityIndicatorCallsCount += 1
        let arguments = style
        showActivityIndicatorReceivedArguments = arguments
        showActivityIndicatorReceivedInvocations.append(arguments)
    }

    // MARK: - hideActivityIndicator

    var hideActivityIndicatorCallsCount = 0

    func hideActivityIndicator() {
        hideActivityIndicatorCallsCount += 1
    }

    // MARK: - hideKeyboard

    var hideKeyboardCallsCount = 0

    func hideKeyboard() {
        hideKeyboardCallsCount += 1
    }

    // MARK: - reloadTableView

    var reloadTableViewCallsCount = 0

    func reloadTableView() {
        reloadTableViewCallsCount += 1
    }

    // MARK: - insert

    var insertCallsCount = 0
    var insertReceivedArguments: Int?
    var insertReceivedInvocations: [Int] = []

    func insert(row: Int) {
        insertCallsCount += 1
        let arguments = row
        insertReceivedArguments = arguments
        insertReceivedInvocations.append(arguments)
    }

    // MARK: - delete

    var deleteCallsCount = 0
    var deleteReceivedArguments: Int?
    var deleteReceivedInvocations: [Int] = []

    func delete(row: Int) {
        deleteCallsCount += 1
        let arguments = row
        deleteReceivedArguments = arguments
        deleteReceivedInvocations.append(arguments)
    }
}
