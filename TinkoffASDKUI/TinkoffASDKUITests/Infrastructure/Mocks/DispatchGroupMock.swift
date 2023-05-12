//
//  DispatchGroupMock.swift
//  TinkoffASDKUI-Unit-Tests
//
//  Created by Aleksandr Pravosudov on 20.04.2023.
//

import Foundation
import XCTest

@testable import TinkoffASDKUI

final class DispatchGroupMock: IDispatchGroup {

    // MARK: - notify

    typealias NotifyArguments = (qos: DispatchQoS, flags: DispatchWorkItemFlags, queue: DispatchQueue, work: () -> Void)

    var notifyCallsCount = 0
    var notifyReceivedArguments: NotifyArguments?
    var notifyReceivedInvocations: [NotifyArguments] = []
    var notifyWorkShouldCalls = false

    func notify(qos: DispatchQoS, flags: DispatchWorkItemFlags, queue: DispatchQueue, execute work: @convention(block) @escaping () -> Void) {
        notifyCallsCount += 1
        let arguments = (qos, flags, queue, work)
        notifyReceivedArguments = arguments
        notifyReceivedInvocations.append(arguments)
        if notifyWorkShouldCalls {
            wait(for: 0.1)
            work()
        }
    }

    // MARK: - enter

    var enterCallsCount = 0

    func enter() {
        enterCallsCount += 1
    }

    // MARK: - leave

    var leaveCallsCount = 0

    func leave() {
        leaveCallsCount += 1
    }
}

private extension DispatchGroupMock {
    func wait(for duration: TimeInterval) {
        let expectation = XCTestExpectation(description: #function)

        DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
            expectation.fulfill()
        }

        XCTWaiter.wait([expectation], timeout: duration + 1)
    }
}

private extension XCTWaiter {
    @discardableResult
    class func wait(_ expectations: [XCTestExpectation], timeout: TimeInterval) -> XCTWaiter.Result {
        wait(for: expectations, timeout: timeout)
    }
}
