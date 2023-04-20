//
//  DispatchGroupMock.swift
//  TinkoffASDKUI-Unit-Tests
//
//  Created by Aleksandr Pravosudov on 20.04.2023.
//

import Foundation
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
