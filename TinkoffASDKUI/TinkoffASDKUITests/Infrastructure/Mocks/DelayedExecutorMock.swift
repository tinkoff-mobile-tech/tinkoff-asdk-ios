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
        get {
            delayGetterCalls += 1
            return underlyingDelay
        }
        set {
            delaySetterCalls += 1
            underlyingDelay = newValue
        }
    }

    var delayGetterCalls = 0
    var delaySetterCalls = 0
    var underlyingDelay: Double = .zero

    var queue: IDispatchQueue {
        get {
            queueGetterCalls += 1
            return underlyingQueue
        }
        set {
            queueSetterCalls += 1
            underlyingQueue = newValue
        }
    }

    var queueGetterCalls = 0
    var queueSetterCalls = 0
    var underlyingQueue: IDispatchQueue = DispatchQueueMock()

    // MARK: - execute

    var executeCallsCount = 0
    var executeReceivedArguments: (() -> Void)?
    var executeReceivedInvocations: [() -> Void] = []
    var executeWorkClosureShouldExecute = false

    func execute(work: @escaping () -> Void) {
        executeCallsCount += 1
        let arguments = work
        executeReceivedArguments = arguments
        executeReceivedInvocations.append(arguments)
        if executeWorkClosureShouldExecute {
            work()
        }
    }
}
