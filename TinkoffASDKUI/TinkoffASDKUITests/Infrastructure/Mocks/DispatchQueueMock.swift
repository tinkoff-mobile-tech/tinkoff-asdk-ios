//
//  DispatchQueueMock.swift
//  TinkoffASDKUI-Unit-Tests
//
//  Created by Aleksandr Pravosudov on 21.04.2023.
//

import Foundation

@testable import TinkoffASDKUI

final class DispatchQueueMock: IDispatchQueue {

    // MARK: - performOnMain

    static var performOnMainCallsCount = 0
    static var performOnMainBlockClosureShouldCalls = false

    static func performOnMain(_ block: @escaping () -> Void) {
        performOnMainCallsCount += 1
        if performOnMainBlockClosureShouldCalls {
            block()
        }
    }

    // MARK: - async

    typealias AsyncArguments = (group: DispatchGroup?, qos: DispatchQoS, flags: DispatchWorkItemFlags, work: () -> Void)

    var asyncCallsCount = 0
    var asyncReceivedArguments: AsyncArguments?
    var asyncReceivedInvocations: [AsyncArguments] = []
    var asyncWorkShouldCalls = false

    func async(group: DispatchGroup?, qos: DispatchQoS, flags: DispatchWorkItemFlags, execute work: @convention(block) @escaping () -> Void) {
        asyncCallsCount += 1
        let arguments = (group, qos, flags, work)
        asyncReceivedArguments = arguments
        asyncReceivedInvocations.append(arguments)
        if asyncWorkShouldCalls {
            work()
        }
    }

    // MARK: - asyncAfter

    typealias AsyncAfterArguments = (deadline: DispatchTime, qos: DispatchQoS, flags: DispatchWorkItemFlags, work: () -> Void)

    var asyncAfterCallsCount = 0
    var asyncAfterReceivedArguments: AsyncAfterArguments?
    var asyncAfterReceivedInvocations: [AsyncAfterArguments] = []
    var asyncAfterShouldCalls = false

    func asyncAfter(deadline: DispatchTime, qos: DispatchQoS, flags: DispatchWorkItemFlags, execute work: @convention(block) @escaping () -> Void) {
        asyncAfterCallsCount += 1
        let arguments = (deadline, qos, flags, work)
        asyncAfterReceivedArguments = arguments
        asyncAfterReceivedInvocations.append(arguments)
        if asyncAfterShouldCalls {
            work()
        }
    }

    // MARK: - asyncDeduped

    typealias AsyncDedupedArguments = (target: AnyObject, delay: TimeInterval, work: () -> Void)

    var asyncDedupedCallsCount = 0
    var asyncDedupedReceivedArguments: AsyncDedupedArguments?
    var asyncDedupedReceivedInvocations: [AsyncDedupedArguments] = []
    var asyncDedupedWorkShouldCalls = false

    func asyncDeduped(target: AnyObject, after delay: TimeInterval, execute work: @convention(block) @escaping () -> Void) {
        asyncDedupedCallsCount += 1
        let arguments = (target, delay, work)
        asyncDedupedReceivedArguments = arguments
        asyncDedupedReceivedInvocations.append(arguments)
        if asyncDedupedWorkShouldCalls {
            work()
        }
    }
}

// MARK: - Public methods

extension DispatchQueueMock {
    static func resetPerformOnMain() {
        DispatchQueueMock.performOnMainCallsCount = 0
        DispatchQueueMock.performOnMainBlockClosureShouldCalls = false
    }
}
