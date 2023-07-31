//
//  DelayedExecutorMock.swift
//  TinkoffASDKUI-Unit-Tests
//
//  Created by Ivan Glushko on 07.07.2023.
//

import Foundation
@testable import TinkoffASDKUI

final class DelayedExecutorMock: IDelayedExecutor {

    var delay: Double {
        get { return underlyingDelay }
        set(value) { underlyingDelay = value }
    }

    var underlyingDelay: Double!

    var queue: IDispatchQueue {
        get { return underlyingQueue }
        set(value) { underlyingQueue = value }
    }

    var underlyingQueue: IDispatchQueue!

    // MARK: - execute

    typealias ExecuteArguments = () -> Void

    var executeCallsCount = 0
    var executeReceivedArguments: ExecuteArguments?
    var executeReceivedInvocations: [ExecuteArguments?] = []
    var executeWorkShouldExecute = false

    func execute(work: @escaping () -> Void) {
        executeCallsCount += 1
        let arguments = work
        executeReceivedArguments = arguments
        executeReceivedInvocations.append(arguments)
        if executeWorkShouldExecute {
            work()
        }
    }
}

// MARK: - Resets

extension DelayedExecutorMock {
    func fullReset() {
        executeCallsCount = 0
        executeReceivedArguments = nil
        executeReceivedInvocations = []
        executeWorkShouldExecute = false
    }
}
