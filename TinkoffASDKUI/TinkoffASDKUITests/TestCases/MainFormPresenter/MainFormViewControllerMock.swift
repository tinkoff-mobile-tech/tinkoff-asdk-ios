//
//  MainFormViewControllerMock.swift
//  TinkoffASDKUI-Unit-Tests
//
//  Created by Aleksandr Pravosudov on 13.06.2023.
//

@testable import TinkoffASDKUI

final class MainFormViewControllerMock: IMainFormViewController {

    // MARK: - showCommonSheet

    typealias ShowCommonSheetArguments = (state: CommonSheetState, animatePullableContainerUpdates: Bool)

    var showCommonSheetCallsCount = 0
    var showCommonSheetReceivedArguments: ShowCommonSheetArguments?
    var showCommonSheetReceivedInvocations: [ShowCommonSheetArguments] = []

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

    var insertRowsCallsCount = 0
    var insertRowsReceivedArguments: [IndexPath]?
    var insertRowsReceivedInvocations: [[IndexPath]] = []

    func insertRows(at indexPaths: [IndexPath]) {
        insertRowsCallsCount += 1
        let arguments = indexPaths
        insertRowsReceivedArguments = arguments
        insertRowsReceivedInvocations.append(arguments)
    }

    // MARK: - deleteRows

    var deleteRowsCallsCount = 0
    var deleteRowsReceivedArguments: [IndexPath]?
    var deleteRowsReceivedInvocations: [[IndexPath]] = []

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
