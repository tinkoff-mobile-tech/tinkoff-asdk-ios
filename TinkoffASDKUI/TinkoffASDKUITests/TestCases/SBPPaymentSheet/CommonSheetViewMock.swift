//
//  CommonSheetViewMock.swift
//  TinkoffASDKUI-Unit-Tests
//
//  Created by Aleksandr Pravosudov on 28.04.2023.
//

import TinkoffASDKCore
@testable import TinkoffASDKUI

final class CommonSheetViewMock: ICommonSheetView {

    // MARK: - update

    typealias UpdateArguments = (state: CommonSheetState, animatePullableContainerUpdates: Bool)

    var updateCallsCount = 0
    var updateReceivedArguments: UpdateArguments?
    var updateReceivedInvocations: [UpdateArguments?] = []

    func update(state: CommonSheetState, animatePullableContainerUpdates: Bool) {
        updateCallsCount += 1
        let arguments = (state, animatePullableContainerUpdates)
        updateReceivedArguments = arguments
        updateReceivedInvocations.append(arguments)
    }

    // MARK: - close

    var closeCallsCount = 0

    func close() {
        closeCallsCount += 1
    }
}

// MARK: - Resets

extension CommonSheetViewMock {
    func fullReset() {
        updateCallsCount = 0
        updateReceivedArguments = nil
        updateReceivedInvocations = []

        closeCallsCount = 0
    }
}
