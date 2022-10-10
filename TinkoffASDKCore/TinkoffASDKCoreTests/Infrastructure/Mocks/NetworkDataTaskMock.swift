//
//  NetworkDataTaskMock.swift
//  TinkoffASDKCore-Unit-Tests
//
//  Created by r.akhmadeev on 10.10.2022.
//

import Foundation
@testable import TinkoffASDKCore

final class NetworkDataTaskMock: INetworkDataTask {
    var invokedResume = false
    var invokedResumeCount = 0

    func resume() {
        invokedResume = true
        invokedResumeCount += 1
    }

    var invokedCancel = false
    var invokedCancelCount = 0

    func cancel() {
        invokedCancel = true
        invokedCancelCount += 1
    }
}
