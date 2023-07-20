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

    typealias PerformOnMainArguments = () -> Void

    static var performOnMainCallsCount = 0
    static var performOnMainReceivedArguments: PerformOnMainArguments?
    static var performOnMainReceivedInvocations: [PerformOnMainArguments] = []
    static var performOnMainBlockShouldExecute = false

    static func performOnMain(_ block: @escaping () -> Void) {
        performOnMainCallsCount += 1
        let arguments = block
        performOnMainReceivedArguments = arguments
        performOnMainReceivedInvocations.append(arguments)
        if performOnMainBlockShouldExecute {
            block()
        }
    }

    // MARK: - async

    typealias AsyncArguments = (group: DispatchGroup?, qos: DispatchQoS, flags: DispatchWorkItemFlags, work: () -> Void)

    var asyncCallsCount = 0
    var asyncReceivedArguments: AsyncArguments?
    var asyncReceivedInvocations: [AsyncArguments] = []
    var asyncWorkShouldExecute = false

    func async(group: DispatchGroup?, qos: DispatchQoS, flags: DispatchWorkItemFlags, execute work: @convention(block) @escaping () -> Void) {
        asyncCallsCount += 1
        let arguments = (group, qos, flags, work)
        asyncReceivedArguments = arguments
        asyncReceivedInvocations.append(arguments)
        if asyncWorkShouldExecute {
            work()
        }
    }

    // MARK: - asyncAfter

    typealias AsyncAfterArguments = (deadline: DispatchTime, qos: DispatchQoS, flags: DispatchWorkItemFlags, work: () -> Void)

    var asyncAfterCallsCount = 0
    var asyncAfterReceivedArguments: AsyncAfterArguments?
    var asyncAfterReceivedInvocations: [AsyncAfterArguments] = []
    var asyncAfterWorkShouldExecute = false

    func asyncAfter(deadline: DispatchTime, qos: DispatchQoS, flags: DispatchWorkItemFlags, execute work: @convention(block) @escaping () -> Void) {
        asyncAfterCallsCount += 1
        let arguments = (deadline, qos, flags, work)
        asyncAfterReceivedArguments = arguments
        asyncAfterReceivedInvocations.append(arguments)
        if asyncAfterWorkShouldExecute {
            work()
        }
    }

    // MARK: - asyncDeduped

    typealias AsyncDedupedArguments = (target: AnyObject, delay: TimeInterval, work: () -> Void)

    var asyncDedupedCallsCount = 0
    var asyncDedupedReceivedArguments: AsyncDedupedArguments?
    var asyncDedupedReceivedInvocations: [AsyncDedupedArguments] = []
    var asyncDedupedWorkShouldExecute = false

    func asyncDeduped(target: AnyObject, after delay: TimeInterval, execute work: @convention(block) @escaping () -> Void) {
        asyncDedupedCallsCount += 1
        let arguments = (target, delay, work)
        asyncDedupedReceivedArguments = arguments
        asyncDedupedReceivedInvocations.append(arguments)
        if asyncDedupedWorkShouldExecute {
            work()
        }
    }
}

// MARK: - Resets

extension DispatchQueueMock {
    static func fullStaticReset() {
        performOnMainCallsCount = 0
        performOnMainReceivedArguments = nil
        performOnMainReceivedInvocations = []
        performOnMainBlockShouldExecute = false
    }

    func fullReset() {
        asyncCallsCount = 0
        asyncReceivedArguments = nil
        asyncReceivedInvocations = []
        asyncWorkShouldExecute = false

        asyncAfterCallsCount = 0
        asyncAfterReceivedArguments = nil
        asyncAfterReceivedInvocations = []
        asyncAfterWorkShouldExecute = false

        asyncDedupedCallsCount = 0
        asyncDedupedReceivedArguments = nil
        asyncDedupedReceivedInvocations = []
        asyncDedupedWorkShouldExecute = false
    }
}
