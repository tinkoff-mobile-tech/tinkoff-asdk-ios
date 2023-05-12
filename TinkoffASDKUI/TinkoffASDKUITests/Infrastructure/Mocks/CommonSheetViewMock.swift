//
//  CommonSheetViewMock.swift
//  Pods
//
//  Created by Ivan Glushko on 20.04.2023.
//

@testable import TinkoffASDKUI

final class CommonSheetViewMock: ICommonSheetView {

    // MARK: - update

    typealias UpdateArguments = (state: CommonSheetState, animateContainerUpdates: Bool)

    var updateCallsCount = 0
    var updateReceivedArguments: UpdateArguments?
    var updateReceivedInvocations: [UpdateArguments] = []

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
