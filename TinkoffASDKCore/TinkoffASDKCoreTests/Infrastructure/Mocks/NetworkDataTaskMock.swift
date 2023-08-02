//
//  NetworkDataTaskMock.swift
//  TinkoffASDKCore-Unit-Tests
//
//  Created by r.akhmadeev on 10.10.2022.
//

import Foundation
@testable import TinkoffASDKCore

final class NetworkDataTaskMock: INetworkDataTask {

    // MARK: - resume

    var resumeCallsCount = 0

    func resume() {
        resumeCallsCount += 1
    }

    // MARK: - cancel

    var cancelCallsCount = 0

    func cancel() {
        cancelCallsCount += 1
    }
}

// MARK: - Resets

extension NetworkDataTaskMock {
    func fullReset() {
        resumeCallsCount = 0

        cancelCallsCount = 0
    }
}
