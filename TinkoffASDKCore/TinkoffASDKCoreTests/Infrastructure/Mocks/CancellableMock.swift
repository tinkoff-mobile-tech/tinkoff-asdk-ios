//
//  CancellableMock.swift
//  TinkoffASDKCore-Unit-Tests
//
//  Created by r.akhmadeev on 24.10.2022.
//

import Foundation
import TinkoffASDKCore

final class CancellableMock: Cancellable {

    // MARK: - cancel

    var cancelCallsCount = 0

    func cancel() {
        cancelCallsCount += 1
    }
}

// MARK: - Resets

extension CancellableMock {
    func fullReset() {
        cancelCallsCount = 0
    }
}
