//
//  MainFormViewControllerMock.swift
//  TinkoffASDKUI-Unit-Tests
//
//  Created by Aleksandr Pravosudov on 13.06.2023.
//

import Foundation
@testable import TinkoffASDKUI

final class MainFormViewControllerMock: IMainFormViewController {

    // MARK: - showCommonSheet

    typealias ShowCommonSheetArguments = (state: CommonSheetState, animatePullableContainerUpdates: Bool)

    var showCommonSheetCallsCount = 0
    var showCommonSheetReceivedArguments: ShowCommonSheetArguments?
    var showCommonSheetReceivedInvocations: [ShowCommonSheetArguments?] = []

    func showCommonSheet(state: CommonSheetState, animatePullableContainerUpdates: Bool) {
        showCommonSheetCallsCount += 1
        let arguments = (state, animatePullableContainerUpdates)
        showCommonSheetReceivedArguments = arguments
        showCommonSheetReceivedInvocations.append(arguments)
    }

    // MARK: - hideCommonSheet

    var hideCommonSheetCallsCount = 0

    func hideCommonSheet() {
        hideCommonSheetCallsCount += 1
    }

    // MARK: - reloadData

    var reloadDataCallsCount = 0

    func reloadData() {
        reloadDataCallsCount += 1
    }

    // MARK: - insertRows

    typealias InsertRowsArguments = [IndexPath]

    var insertRowsCallsCount = 0
    var insertRowsReceivedArguments: InsertRowsArguments?
    var insertRowsReceivedInvocations: [InsertRowsArguments?] = []

    func insertRows(at indexPaths: [IndexPath]) {
        insertRowsCallsCount += 1
        let arguments = indexPaths
        insertRowsReceivedArguments = arguments
        insertRowsReceivedInvocations.append(arguments)
    }

    // MARK: - deleteRows

    typealias DeleteRowsArguments = [IndexPath]

    var deleteRowsCallsCount = 0
    var deleteRowsReceivedArguments: DeleteRowsArguments?
    var deleteRowsReceivedInvocations: [DeleteRowsArguments?] = []

    func deleteRows(at indexPaths: [IndexPath]) {
        deleteRowsCallsCount += 1
        let arguments = indexPaths
        deleteRowsReceivedArguments = arguments
        deleteRowsReceivedInvocations.append(arguments)
    }

    // MARK: - hideKeyboard

    var hideKeyboardCallsCount = 0

    func hideKeyboard() {
        hideKeyboardCallsCount += 1
    }

    // MARK: - closeView

    var closeViewCallsCount = 0

    func closeView() {
        closeViewCallsCount += 1
    }
}

// MARK: - Resets

extension MainFormViewControllerMock {
    func fullReset() {
        showCommonSheetCallsCount = 0
        showCommonSheetReceivedArguments = nil
        showCommonSheetReceivedInvocations = []

        hideCommonSheetCallsCount = 0

        reloadDataCallsCount = 0

        insertRowsCallsCount = 0
        insertRowsReceivedArguments = nil
        insertRowsReceivedInvocations = []

        deleteRowsCallsCount = 0
        deleteRowsReceivedArguments = nil
        deleteRowsReceivedInvocations = []

        hideKeyboardCallsCount = 0

        closeViewCallsCount = 0
    }
}
