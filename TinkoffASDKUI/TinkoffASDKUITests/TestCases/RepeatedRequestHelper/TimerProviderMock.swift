//
//  TimerProviderMock.swift
//  TinkoffASDKUI-Unit-Tests
//
//  Created by Aleksandr Pravosudov on 28.06.2023.
//

import Foundation
@testable import TinkoffASDKUI

final class TimerProviderMock: ITimerProvider {

    // MARK: - invalidateTimer

    var invalidateTimerCallsCount = 0

    func invalidateTimer() {
        invalidateTimerCallsCount += 1
    }

    // MARK: - executeTimer

    typealias ExecuteTimerArguments = (timeInterval: TimeInterval, repeats: Bool, action: () -> Void)

    var executeTimerCallsCount = 0
    var executeTimerReceivedArguments: ExecuteTimerArguments?
    var executeTimerReceivedInvocations: [ExecuteTimerArguments] = []
    var executeTimerActionShouldExecute: Bool = false

    func executeTimer(timeInterval: TimeInterval, repeats: Bool, action: @escaping () -> Void) {
        executeTimerCallsCount += 1
        let arguments = (timeInterval, repeats, action)
        executeTimerReceivedArguments = arguments
        executeTimerReceivedInvocations.append(arguments)
        if executeTimerActionShouldExecute {
            action()
        }
    }

    // MARK: - executeTimer helper

    func executeTimer(timeInterval: TimeInterval, action: @escaping () -> Void) {
        executeTimer(timeInterval: timeInterval, repeats: false, action: action)
    }
}
