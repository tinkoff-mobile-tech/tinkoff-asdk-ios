//
//  DispatchQueueMock.swift
//  TinkoffASDKUI-Unit-Tests
//
//  Created by Aleksandr Pravosudov on 21.04.2023.
//

import Foundation

@testable import TinkoffASDKUI

final class DispatchQueueMock: IDispatchQueue {

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
}
