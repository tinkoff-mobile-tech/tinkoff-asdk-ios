//
//  SBPQrViewInputMock.swift
//  TinkoffASDKUI-Unit-Tests
//
//  Created by Aleksandr Pravosudov on 15.05.2023.
//

@testable import TinkoffASDKUI

final class SBPQrViewInputMock: ISBPQrViewInput {

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

    // MARK: - closeView

    var closeViewCallsCount = 0

    func closeView() {
        closeViewCallsCount += 1
    }
}

// MARK: - Resets

extension SBPQrViewInputMock {
    func fullReset() {
        showCommonSheetCallsCount = 0
        showCommonSheetReceivedArguments = nil
        showCommonSheetReceivedInvocations = []

        hideCommonSheetCallsCount = 0

        reloadDataCallsCount = 0

        closeViewCallsCount = 0
    }
}
