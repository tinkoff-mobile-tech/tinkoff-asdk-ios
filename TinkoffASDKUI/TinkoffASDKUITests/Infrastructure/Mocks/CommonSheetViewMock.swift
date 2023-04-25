//
//  CommonSheetViewMock.swift
//  Pods
//
//  Created by Ivan Glushko on 20.04.2023.
//

@testable import TinkoffASDKUI

final class CommonSheetViewMock: ICommonSheetView {

    // MARK: - update

    var updateCallsCount = 0
    var updateReceivedArguments: CommonSheetState?
    var updateReceivedInvocations: [CommonSheetState] = []

    func update(state: CommonSheetState) {
        updateCallsCount += 1
        let arguments = state
        updateReceivedArguments = arguments
        updateReceivedInvocations.append(arguments)
    }

    // MARK: - close

    var closeCallsCount = 0

    func close() {
        closeCallsCount += 1
    }
}
