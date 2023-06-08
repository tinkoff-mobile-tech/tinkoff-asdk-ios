//
//  RepeatedRequestHelperMock.swift
//  TinkoffASDKUI-Unit-Tests
//
//  Created by Aleksandr Pravosudov on 28.04.2023.
//

import TinkoffASDKCore
@testable import TinkoffASDKUI

final class RepeatedRequestHelperMock: IRepeatedRequestHelper {

    // MARK: - executeWithWaitingIfNeeded

    var executeWithWaitingIfNeededCallsCount = 0
    var executeWithWaitingIfNeededActionShouldCalls = false

    func executeWithWaitingIfNeeded(action: @escaping () -> Void) {
        executeWithWaitingIfNeededCallsCount += 1
        if executeWithWaitingIfNeededActionShouldCalls {
            action()
        }
    }
}
